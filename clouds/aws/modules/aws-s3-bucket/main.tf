locals {
  cloudtrail_name   = "${var.bucket_name}-s3s"
  cloudtrail_bucket = "${var.bucket_name}-logs"
  dynamo_tf_lock    = "${var.bucket_name}-tf-lock"
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

  # Note: Object Lock configuration can be enabled only on new buckets
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration
  object_lock_enabled = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  }

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

########################
# CloudTrail Logging
########################

resource "aws_cloudtrail" "s3_cloudtrail" {
  count          = var.enable_logging ? 1 : 0
  name           = local.cloudtrail_name
  s3_bucket_name = module.aws_s3_logs.s3_bucket_id
  depends_on     = [aws_s3_bucket_policy.cloudtrail_s3_policy]

  event_selector {
    read_write_type = "All"

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${var.bucket_name}/*"]
    }
  }
}

module "aws_s3_logs" {
  # checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  # checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "3.4.0"
  create_bucket = var.enable_logging

  bucket = local.cloudtrail_bucket

  force_destroy = var.force_destroy

  #https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${local.cloudtrail_bucket}",
            "Condition": {
                "StringEquals": {
                    "aws:SourceArn": "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
                }
            }
        },
        {
            "Sid": "AWSCloudTrailWriteAccount",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.cloudtrail_bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "AWS:SourceArn" : "arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"
                }
            }
        }
    ]
}
POLICY


  tags = var.tags
}

data "aws_iam_policy_document" "cloudtrail_s3" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [module.aws_s3_logs.s3_bucket_arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${module.aws_s3_logs.s3_bucket_arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${local.cloudtrail_name}"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_s3_policy" {
  /* count  = var.enable_logging ? 1 : 0 */
  count  = 0
  bucket = module.aws_s3_logs.s3_bucket_id
  policy = data.aws_iam_policy_document.cloudtrail_s3.json
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

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
