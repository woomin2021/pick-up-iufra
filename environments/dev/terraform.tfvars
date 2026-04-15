project_name = "pickup"
environment  = "dev"
aws_region   = "ap-northeast-2"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]

public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
eks_subnet_cidrs      = ["10.0.3.0/24", "10.0.4.0/24"]
realtime_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
data_subnet_cidrs     = ["10.0.7.0/24", "10.0.8.0/24"]
