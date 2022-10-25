
variable "availability_zones" {
  description = "AZs in this region to use"
  type = list
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  type = string
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets"
  type = list
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets"
  type = list
}

variable "environment" {
  description = "Environment name to identify the owner of the application"
  type = string
}