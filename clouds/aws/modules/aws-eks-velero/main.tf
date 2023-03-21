data "aws_region" "current" {}

module "aws_s3_backups" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.4.0"

  bucket = var.bucket_name

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

module "velero_eks_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "velero-${var.bucket_name}"
  attach_velero_policy  = true
  velero_s3_bucket_arns = [module.aws_s3_backups.s3_bucket_arn]

  oidc_providers = {
    main = {
      provider_arn               = var.k8s_cluster_oidc_arn
      namespace_service_accounts = ["${var.namespace}:${local.service_account}"]
    }
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

locals {
  aws_region      = data.aws_region.current.name
  service_account = "velero-${local.aws_region}"
}

resource "helm_release" "this" {
  depends_on = [kubernetes_namespace.this]

  chart      = "velero"
  name       = var.release_name
  namespace  = var.namespace
  repository = "https://vmware-tanzu.github.io/helm-charts"
  values = [templatefile("${path.module}/values.yaml", {
    bucket_name          = module.aws_s3_backups.s3_bucket_id,
    velero_region        = local.aws_region,
    rol_arn              = module.velero_eks_role.iam_role_arn
    service_account_name = local.service_account
  })]
  version = var.chart_version
}
