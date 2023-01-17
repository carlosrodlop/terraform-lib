provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.tags
  }
}

data "aws_route53_zone" "domain" {
  name = var.domain_name
}

# For VPC
#data "aws_availability_zones" "available" {}

locals {
  lab             = basename(abspath(path.module))
  name            = "${var.preffix}-${local.lab}"
  backend_name    = "${local.name}.state"
  table_lock_name = "${local.name}.lock"

  #vpc_cidr = "10.0.0.0/16"
  #azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = merge(var.tags, {
    "tf:blueprints" = local.name
  })
}

module "acm_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id     = data.aws_route53_zone.domain.id

  # This matches with Route 53 Zone Name
  subject_alternative_names = [
    "*.${var.domain_name}",
  ]

  wait_for_validation = true

}

module "s3_state" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.4.0"

  bucket = local.backend_name

  # Allow deletion of non-empty bucket
  # NOTE: This is enabled for example usage only, you should not enable this for production workloads
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  acl = "private"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  versioning = {
    status     = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "block_table" {
  # checkov:skip=CKV_AWS_28:"Ensure Dynamodb point in time recovery (backup) is enabled"
  # checkov:skip=CKV_AWS_119:"Ensure DynamoDB Tables are encrypted using a KMS Customer Managed CMK"
  # checkov:skip=CKV2_AWS_16:"Ensure that Auto Scaling is enabled on your DynamoDB tables"
  name           = local.table_lock_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

#NOTE: VPC Subnets cannot be a shared resource
#EKS requirement "kubernetes.io/cluster/${cluster_name}" = "shared" https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
#https://github.com/hashicorp/terraform/issues/17352#issuecomment-550549330
#Possible workarounds
# 1.- Create a VPC shared but configure the subnet in each of the cluster labs https://aws.plainenglish.io/infra-as-code-create-aws-vpc-and-subnets-using-terraform-and-best-practices-eaba8c3e1aef
# 2.- https://github.com/hashicorp/terraform/issues/17352#issuecomment-486943045

/* module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

} */
