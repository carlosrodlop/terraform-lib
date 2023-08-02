output "bucket_name" {
  description = "AWS S3 Bucket state"
  value       = module.aws_s3.s3_bucket_id
}

output "dynamo_table_lock_name" {
  description = "AWS Dynamo Table lock"
  value       = var.is_tf_backend ? aws_dynamodb_table.block_table[0].id : null
}
