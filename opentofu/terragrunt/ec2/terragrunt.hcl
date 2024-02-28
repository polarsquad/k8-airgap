terraform {
  source = "../../modules/ec2"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "${get_repo_root()}/opentofu/terragrunt/vpc"
}
generate "versions.tf" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "aws" {
        region  = var.aws_region
        profile = var.profile
    }
    EOF
}

inputs = {
    key_name           = "k8-airgap-keypair"
    aws_region         = get_env("AWS_REGION", "eu-west-1")
    profile            = get_env("AWS_PROFILE", "polarsquad")
    keypair_path       = "${get_repo_root()}/ansible"
    vpc_id             = dependency.vpc.outputs.vpc_id
    subnet_ids         = dependency.vpc.outputs.public_subnets
    count_master_nodes = 3
    count_agent_nodes  = 2
    ec2_ami            = "ami-0905a3c97561e0b69"
    instance_type      = "t3.xlarge"
}
