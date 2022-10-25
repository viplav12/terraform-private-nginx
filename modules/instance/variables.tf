variable "environment" {
  description = "Environment to be used for deployment of the application"
  type = string
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets"
  type = list
}

variable "vpc_id" {
  description = "VPC id for target group"
  type = string
}

variable "private_security_id" {
  description = "Private security group to be attached to instance"
  type = string
}

variable "private_subnetid" {
  description = "Private security group to be attached to instance"
  type = list
}

variable "alb_arn" {
  description = "Load balancer ARN"
  type = string
}

variable "instance_ami_id" {
  description = "Amazon Linux AMI id for instance creation"
  type = string
  default = "ami-070b208e993b59cea"
}

variable "instance_size" {
  description = "Linux instance type and size"
  type = string
  default = "t2.micro"
}