terraform {
  source = "../../modules/ec2"
}

include {
  path = find_in_parent_folders()
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
    key_name = "k8-airgap-keypair"
    aws_region = get_env("AWS_REGION", "eu-west-1")
    profile = get_env("AWS_PROFILE", "polarsquad")
    keypair_path = "${get_repo_root()}/ansible"
}
