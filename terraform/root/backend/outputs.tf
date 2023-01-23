output "backend_name" {
  description = "AWS S3 Bucket state"
  value       = var.backend_name
}

output "dynamo_table_lock_name" {
  description = "AWS Dynamo Table lock"
  value       = local.table_lock_name
}
