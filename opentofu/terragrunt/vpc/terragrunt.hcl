terraform {
  source = "../../modules/vpc"
}

include {
  path = find_in_parent_folders()
}

generate "versions.tf" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = ">= 5.20"
        }
    }
    }
    provider "aws" {
        region  = var.aws_region
        profile = var.profile
    }
    EOF
}

inputs = {
    vpc_name = "vpc-k8-airgap"
    cidr = "10.100.0.0/16"
    environment = "dev"
    aws_region = get_env("AWS_REGION", "eu-west-1")
    profile = get_env("AWS_PROFILE", "polarsquad")
}
