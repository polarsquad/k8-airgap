module "key-pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.2"
  key_name           = var.key_name
  create_private_key = true
}

resource "local_sensitive_file" "this" {
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
  count         = var.count_master_nodes
  ami           = var.ec2_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.k8-airgap-sg.id]
  root_block_device {
    volume_size =  50
    tags = {
      Name = "master_nodes_${count.index}"
    }
  }
  tags = {
    Name = "master_nodes_${count.index}"
  }
}


resource "aws_instance" "agent_nodes" {
  count         = var.count_agent_nodes
  ami           = var.ec2_ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.k8-airgap-sg.id]
  root_block_device {
    volume_size =  50
    tags = {
      Name = "agent_nodes_${count.index}"
    }
  }
  tags = {
    Name = "agent_nodes_${count.index}"
  }
}