# Calling module which will first create the networking along with another call for instance
## creation along with user-data script which runs the nginx container
module "knab_networking" {
  source               = "./modules/networking"
  subnet_cidrs_private = var.subnet_cidrs_private
  subnet_cidrs_public  = var.subnet_cidrs_public
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  environment          = var.environment
}

