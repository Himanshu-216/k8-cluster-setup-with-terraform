variable "name" {
  description = "Cluster name prefix"
  type        = string
  default     = "k8s-demo"
}

variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "master_count" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "master_instance_type" {
  description = "Instance type for master nodes"
  type        = string
  default     = "t3.medium"
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.small"
}

variable "master_user_data" {
  description = "User data script for master nodes"
  type        = string
  default     = ""
}

variable "worker_user_data" {
  description = "User data script for worker nodes"
  type        = string
  default     = ""
}
