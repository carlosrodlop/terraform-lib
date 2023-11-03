locals {
  dynamo_tf_lock = "${var.bucket_name}-tf-lock"
}

module "aws_s3" {
  # checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  # checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.4.0"

  bucket = var.bucket_name

  force_destroy = var.force_destroy

  # Bucket policies
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 Bucket Ownership Controls
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    status     = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.bucket_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  object_lock_enabled = var.enable_object_lock
  object_lock_configuration = var.enable_object_lock ? {
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  } : {}

  tags = var.tags
}

########################
# KMS: Custom Key
########################

resource "aws_kms_key" "bucket_key" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.bucket_name}"
  target_key_id = aws_kms_key.bucket_key.key_id
}

########################################
# Terraform Backend only: Block state
########################################

resource "aws_dynamodb_table" "block_table" {
  # checkov:skip=CKV_AWS_28:"Ensure Dynamodb point in time recovery (backup) is enabled"
  # checkov:skip=CKV_AWS_119:"Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK"
  # checkov:skip=CKV2_AWS_16:"Ensure that Auto Scaling is enabled on your DynamoDB tables"

  count          = var.is_tf_backend ? 1 : 0
  name           = local.dynamo_tf_lock
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}
