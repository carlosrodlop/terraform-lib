output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "The private subnets of the VPC"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "The private subnets of the VPC"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "first_public_subnet" {
  description = "First public subnet of the VPC"
  value       = module.vpc.public_subnets[0]
}
