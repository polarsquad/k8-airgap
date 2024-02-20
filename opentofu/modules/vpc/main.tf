data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subnets = chunklist(cidrsubnets(var.cidr, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4), length(data.aws_availability_zones.available.names))
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = var.vpc_name
  cidr = var.cidr

  azs                     = data.aws_availability_zones.available.names
  private_subnets         = local.subnets[0]
  public_subnets          = local.subnets[1]
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  tags = {
    "IaC"         = "true"
    "Environment" = var.environment
  }
}
