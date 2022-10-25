variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  default     = "10.0.0.0/16"
  type        = string
}

variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  type        = list(any)
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  type        = list(any)
}

variable "environment" {
  description = "Environment to be used for deployment of the application"
  default     = "acceptance"
  type        = string
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default     = ["eu-central-1a", "eu-central-1b"]
  type        = list(any)
}
