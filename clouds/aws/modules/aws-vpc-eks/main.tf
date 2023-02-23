data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  #https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.name
  cidr = var.cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.name}-default" }

  public_subnet_tags = var.public_subnet_tags

  private_subnet_tags = var.private_subnet_tags

  tags = local.tags

}
