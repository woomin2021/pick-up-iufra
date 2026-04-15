output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "eks_subnet_ids" {
  value = module.vpc.eks_subnet_ids
}

output "realtime_subnet_ids" {
  value = module.vpc.realtime_subnet_ids
}

output "data_subnet_ids" {
  value = module.vpc.data_subnet_ids
}
