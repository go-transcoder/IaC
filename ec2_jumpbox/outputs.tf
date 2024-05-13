output "private_key_pem" {
  description = "Private key data in PEM (RFC 1421) format"
  value       = try(trimspace(tls_private_key.main_ec2_private[0].private_key_pem), "")
  sensitive   = true
}

output "security_group_id" {
  value = module.jump_box_security_group.security_group_id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}