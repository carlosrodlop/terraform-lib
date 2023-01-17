provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.tags
  }
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {}

locals {
  lab              = basename(abspath(path.module))
  workspace_suffix = terraform.workspace == "default" ? "" : "_${terraform.workspace}"
  name             = "${var.preffix}_${local.lab}${local.workspace_suffix}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = merge(var.tags, {
    "tf:blueprints" = local.lab
  })

  vpc_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
  }

  kubeconfig_file = "${path.cwd}/kube.${local.lab}.conf"
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.20.0"

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    egress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }

    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_ssh_all = {
      description      = "Egress all ssh to internet for github"
      protocol         = "tcp"
      from_port        = 22
      to_port          = 22
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      #https://aws.amazon.com/ec2/instance-types/
      instance_types = ["m5.8xlarge"]
      min_size       = 3
      max_size       = 6
      desired_size   = 3
      subnet_ids     = module.vpc.private_subnets
    }
  }

}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.20.0"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Add-ons
  enable_metrics_server     = true
  enable_cluster_autoscaler = true

}

#---------------------------------------------------------------
# Supporting Resources
#---------------------------------------------------------------

module "vpc" {
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
    "kubernetes.io/cluster/${local.name}" = "owned"
    "kubernetes.io/role/elb"              = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "owned"
    "kubernetes.io/role/internal-elb"     = "1"
  }

  tags = local.vpc_tags

}

################################################################################
# Post-provisioning commands
################################################################################

resource "null_resource" "update_kubeconfig" {
  #count = var.create_kubeconfig_file ? 1 : 0

  provisioner "local-exec" {
    command = "${module.eks_blueprints.configure_kubectl} --kubeconfig ${local.kubeconfig_file}"
  }
}

################################################################################
# Testing
################################################################################

data "aws_route53_zone" "domain" {
  name = var.domain_name
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name
  oidc_issuer    = module.eks_blueprints.eks_oidc_issuer_url
}

module "acm_certificate" {
  #for_each = var.create_acm_certificate ? local.this : []
  source = "../../modules/ryecarrigan-cb-tf/modules/acm-certificate"

  domain_name = var.domain_name
  subdomain   = "*"
}

module "aws_load_balancer_controller" {
  depends_on = [module.eks_blueprints]
  source     = "../../modules/ryecarrigan-cb-tf/modules/aws-load-balancer-controller"

  aws_account_id            = local.aws_account_id
  aws_region                = local.aws_region
  cluster_name              = local.name
  cluster_security_group_id = module.eks_blueprints.cluster_security_group_id
  node_security_group_id    = module.eks_blueprints.worker_node_security_group_id
  oidc_issuer               = local.oidc_issuer
}

module "external_dns" {
  depends_on = [module.eks_blueprints]
  source     = "../../modules/ryecarrigan-cb-tf/modules/external-dns-eks"

  aws_account_id  = local.aws_account_id
  cluster_name    = local.name
  oidc_issuer     = local.oidc_issuer
  route53_zone_id = data.aws_route53_zone.domain.id
}
