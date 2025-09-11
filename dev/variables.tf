variable "master_count" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 0
}

variable "master_instance_type" {
  description = "EC2 type for masters"
  type        = string
  default     = "t2.medium"
}

variable "worker_instance_type" {
  description = "EC2 type for workers"
  type        = string
  default     = "t2.micro"
}
