output "dev_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_dev.public_ips
}

# output "eip" {
#   description = "Public IP address of the EC2 instance"
#   value       = module.ec2_dev.elastic_ip
# }