output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

output "backend_name" {
  description = "AWS S3 Bucket state"
  value       = local.backend_name
}

output "dynamo_table_lock_name" {
  description = "AWS Dynamo Table lock"
  value       = local.table_lock_name
}

/* output "vpc_id" {
  description = "AWS VPC id"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "VPC public subnet CIDR"
  value       = module.vpc.private_subnets
} */
