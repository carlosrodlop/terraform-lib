# Terraform S3 Backend Best Practices
# https://technology.doximity.com/articles/terraform-s3-backend-best-practices

resource "aws_kms_key" "terraform_bucket_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform_bucket_key.key_id
}

resource "aws_s3_bucket" "terraform_state" {
  # checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  # checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  bucket = var.backend_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.terraform_bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "block_table" {
  # checkov:skip=CKV_AWS_28:"Ensure Dynamodb point in time recovery (backup) is enabled"
  # checkov:skip=CKV_AWS_119:"Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK"
  # checkov:skip=CKV2_AWS_16:"Ensure that Auto Scaling is enabled on your DynamoDB tables"
  name           = "terraform-state"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
