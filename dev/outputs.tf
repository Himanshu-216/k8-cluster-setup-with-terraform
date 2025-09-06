output "master_public_ips" {
  value       = module.ec2_cluster.master_public_ips
  description = "Public IPs of master nodes"
}

output "worker_public_ips" {
  value       = module.ec2_cluster.worker_public_ips
  description = "Public IPs of worker nodes"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}
