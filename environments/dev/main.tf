module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs   = var.public_subnet_cidrs
  eks_subnet_cidrs      = var.eks_subnet_cidrs
  realtime_subnet_cidrs = var.realtime_subnet_cidrs
  data_subnet_cidrs     = var.data_subnet_cidrs
}
