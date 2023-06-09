output "security_group_id" {
  description = "Security Group ID for the Bastion Host"
  value       = aws_security_group.this.id
}

output "bastion_ssh_connection_string" {
  description = "SSH connection string for the Bastion Host. Replace <pathToTheKey> to the path to the public key."
  value       = "ssh -i <pathToTheKey>/${var.key_name}.pem ${var.instance_user}@${aws_instance.this.public_dns}"
}
