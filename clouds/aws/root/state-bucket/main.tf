provider "aws" {
  default_tags {
    tags = local.tags
  }
}

locals {
  root             = basename(abspath(path.module))
  workspace_suffix = terraform.workspace == "default" ? "" : "_${terraform.workspace}"
  name             = "${var.preffix}${local.workspace_suffix}"
  backend_name     = "${local.name}.tf_state"

  tags = merge(var.tags, {
    "tf:blueprint_root" = local.root
  })

}

module "aws_s3_backend" {
  count  = var.deploy_buckend ? 1 : 0
  source = "../../modules/aws-s3-backend"

  backend_name = local.backend_name
}
