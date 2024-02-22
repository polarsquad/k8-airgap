module "key-pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.2"
  key_name           = var.key_name
  create_private_key = true
}

resource "local_sensitive_file" "key-pair" {
  content  = module.key-pair.private_key_pem
  filename = "${var.keypair_path}/${var.key_name}"
}


resource "aws_security_group" "k8-airgap-sg" {
  name        = "k8-airgap-sg"
  description = "Security group fo an airgap k8 cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "k8-airgap-sg"
  }
}

resource "aws_security_group_rule" "ingress-self" {
  security_group_id = aws_security_group.k8-airgap-sg.id
  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  self              = true
  description       = "Allow inbound traffic from the same security group"
}
resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.k8-airgap-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = [var.public_ip]
  description       = "Allow SSH from the public IP"
}
resource "aws_security_group_rule" "egress-self" {
  security_group_id = aws_security_group.k8-airgap-sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  self              = true
  description       = "Allow outbound traffic from the same security group"
}


resource "aws_instance" "master_nodes" {
  depends_on = [
    module.key-pair
  ]
  count                  = var.count_master_nodes
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.k8-airgap-sg.id]
  root_block_device {
    volume_size = 50
    tags = {
      Name = "master_nodes_${count.index}"
    }
  }
  tags = {
    Name = "master_nodes_${count.index}"
  }
}


resource "aws_instance" "agent_nodes" {
  depends_on = [
    module.key-pair
  ]
  count                  = var.count_agent_nodes
  ami                    = var.ec2_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.k8-airgap-sg.id]
  root_block_device {
    volume_size = 50
    tags = {
      Name = "agent_nodes_${count.index}"
    }
  }
  tags = {
    Name = "agent_nodes_${count.index}"
  }
}

resource "aws_eip" "master_nodes" {
  count    = var.count_master_nodes
  instance = aws_instance.master_nodes[count.index].id
  domain   = "vpc"
}

resource "aws_eip" "agent_nodes" {
  count    = var.count_agent_nodes
  instance = aws_instance.agent_nodes[count.index].id
  domain   = "vpc"
}


data "aws_instance" "master_nodes" {
  depends_on = [
    aws_eip.master_nodes
  ]
  count = var.count_master_nodes
  instance_id = aws_instance.master_nodes[count.index].id
}
data "aws_instance" "agent_nodes" {
  depends_on = [
    aws_eip.agent_nodes
  ]
  count = var.count_agent_nodes
  instance_id = aws_instance.agent_nodes[count.index].id
}

resource "random_password" "rke2_token" {
  length  = 16
  special = false
}


resource "local_file" "inventory" {
  content  = templatefile("${path.module}/inventory.tftpl", { keypair_path = "${var.keypair_path}/${var.key_name}", master_nodes_public_dns = data.aws_instance.master_nodes[*].public_dns, agent_nodes_public_dns = data.aws_instance.agent_nodes[*].public_dns })
  filename = "${var.keypair_path}/inventory.ini"
}
resource "local_file" "master_nodes_configs" {
  count    = var.count_master_nodes
  content  = templatefile("${path.module}/config.tftpl", { node_name = data.aws_instance.master_nodes[count.index].public_dns, rke2_token = random_password.rke2_token.result, master_dns = data.aws_instance.master_nodes[0].public_dns, exclude = count.index == 0, master_nodes_public_dns = data.aws_instance.master_nodes[*].public_dns, agent_nodes_public_dns = data.aws_instance.agent_nodes[*].public_dns })
  filename = "${var.keypair_path}/artifacts/rke2/master_nodes/${data.aws_instance.master_nodes[count.index].public_dns}/config.yaml"
}

resource "local_file" "agents_nodes_configs" {
  depends_on = [
    aws_eip.agent_nodes
  ]
  count    = var.count_agent_nodes
  content  = templatefile("${path.module}/config.tftpl", { node_name = data.aws_instance.agent_nodes[count.index].public_dns, rke2_token = random_password.rke2_token.result, master_dns = data.aws_instance.master_nodes[0].public_dns, exclude = false, master_nodes_public_dns = data.aws_instance.master_nodes[*].public_dns, agent_nodes_public_dns = data.aws_instance.agent_nodes[*].public_dns })
  filename = "${var.keypair_path}/artifacts/rke2/agent_nodes/${data.aws_instance.agent_nodes[count.index].public_dns}/config.yaml"
}
