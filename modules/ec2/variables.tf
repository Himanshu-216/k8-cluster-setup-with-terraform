variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "name" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}
variable "user_data" {
  type    = string
  default = ""
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

