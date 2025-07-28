variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "name" {
  type        = string
  description = "Name prefix for VPC resources"
}

variable "public_subnet_cidr_a" {
  type        = string
  description = "CIDR block for public subnet in AZ A"
}

variable "public_subnet_cidr_b" {
  type        = string
  description = "CIDR block for public subnet in AZ B"
}

variable "private_subnet_cidr_a" {
  type        = string
  description = "CIDR block for private subnet in AZ A"
}

variable "private_subnet_cidr_b" {
  type        = string
  description = "CIDR block for private subnet in AZ B"
}

variable "availability_zone_a" {
  type        = string
  description = "Availability Zone A"
}

variable "availability_zone_b" {
  type        = string
  description = "Availability Zone B"
}
