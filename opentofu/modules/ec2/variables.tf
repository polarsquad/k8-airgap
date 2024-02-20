variable "key_name" {
  description = "key_name"
  type = string
  default = "polarkey"
}

variable "keypair_path" {
  description = "keypair_path"
  type = string
  default = "/tmp"
}

variable "vpc_id" {
  description = "vpc_id"
  type = string
  default = "vpc-0a5d3c1d"
}

variable "count_master_nodes" {
  description = "count_master_nodes"
  type = number
  default = 1
}

variable "count_agent_nodes" {
  description = "count_agent_nodes"
  type = number
  default = 1
}

variable "ec2_ami" {
  description = "ec2_ami"
  type = string
  default = "ami-0905a3c97561e0b69"
}

variable "instance_type" {
  description = "instance_type"
  type = string
  default = "t3.micro"
  
}

variable "public_ip" {
  description = "public_ip"
  type = string
  default = "0.0.0.0/32"
}

variable "subnet_ids" {
  description = "subnet_ids"
  type = list(string)
  default = ["subnet-0a5d3c1d"]
}
