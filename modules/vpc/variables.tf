variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets (ALB, NAT GW)"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "eks_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for EKS worker node subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "realtime_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for realtime subnets (Redis)"
  default     = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "data_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for data subnets (RDS)"
  default     = ["10.0.7.0/24", "10.0.8.0/24"]
}
