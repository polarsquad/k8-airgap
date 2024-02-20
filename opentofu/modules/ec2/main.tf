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
