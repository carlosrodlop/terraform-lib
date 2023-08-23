output "bucket_name" {
  description = "AWS S3 Bucket state"
  value       = module.aws_s3_backend.bucket_name
}

output "dynamo_table_lock_name" {
  description = "AWS Dynamo Table lock"
  value       = module.aws_s3_backend.dynamo_table_lock_name
}

output "aws_region" {
  description = "AWS Dynamo Table lock"
  value       = data.aws_region.current.name
}
