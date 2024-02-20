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