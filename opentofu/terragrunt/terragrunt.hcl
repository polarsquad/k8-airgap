remote_state {
  backend = "s3"
  config = {
    bucket         = get_env("SATE_BUCKET", "polarsquad-k8-arigap-iac-state")
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = get_env("AWS_REGION", "eu-west-1")
    encrypt        = true
    dynamodb_table = get_env("SATE_BUCKET", "polarsquad-k8-arigap-iac-state")
    profile        = get_env("AWS_PROFILE", "polarsquad")
  }
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
}

generate "common_variables.tf" {
  path      = "common_variables.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    variable "profile" {
        description = "profile"
        default     = "polarsquad"
        type        = string
    }

    variable "aws_region" {
        description = "aws_region"
        default     = "eu-west-1"
        type        = string
    
    }
    EOF
}