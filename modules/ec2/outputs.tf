### modules/ec2/outputs.tf
output "instance_ids" {
  value = aws_instance.this[*].id
}

output "public_ips" {
  value = [for instance in aws_instance.this : instance.public_ip]
}



