output "private_key_id" {
  description = "Unique identifier for this resource: hexadecimal representation of the SHA1 checksum of the resource"
  value       = module.key-pair.private_key_id
}

output "private_key_pem" {
  description = "Private key data in PEM (RFC 1421) format"
  value       = module.key-pair.private_key_pem
  sensitive   = true
}