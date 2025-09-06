# Master outputs
output "master_public_ips" {
  description = "Public IPs of master nodes"
  value       = aws_instance.masters[*].public_ip
}

output "master_private_ips" {
  description = "Private IPs of master nodes"
  value       = aws_instance.masters[*].private_ip
}

# Worker outputs
output "worker_public_ips" {
  description = "Public IPs of worker nodes"
  value       = aws_instance.workers[*].public_ip
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes"
  value       = aws_instance.workers[*].private_ip
}

# Keypair file path
output "private_key_pem" {
  description = "Private key PEM file generated locally"
  value       = local_file.private_key_pem.filename
  sensitive   = true
}
