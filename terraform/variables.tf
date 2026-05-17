variable "aws_region" {
  description = "AWS region for the EC2 instance"
  type        = string
  default     = "ap-southeast-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = ""
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH into the instance"
  type        = string
  default     = "0.0.0.0/0"
}