provider "aws" {
  #https://github.com/hashicorp/terraform-provider-aws/issues/19583
  /* default_tags {
    tags = local.tags
  } */
}

data "aws_region" "current" {}

locals {
  root             = basename(abspath(path.module))
  workspace_suffix = terraform.workspace == "default" ? "" : "_${terraform.workspace}"
  name             = "${var.preffix}${local.workspace_suffix}"
  backend_name     = "${local.name}-tf-state"

  tags = merge(var.tags, {
    "tf:blueprint_root" = local.root
  })

}

module "aws_s3_backend" {
  source = "../../modules/aws-s3-bucket"

  bucket_name    = local.backend_name
  force_destroy  = true
  enable_logging = false
  is_tf_backend  = true
  tags           = local.tags
}
