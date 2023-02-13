provider "aws" {
  default_tags {
    tags = local.tags
  }
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

locals {
  root             = basename(abspath(path.module))
  workspace_suffix = terraform.workspace == "default" ? "" : "_${terraform.workspace}"
  name             = "${var.preffix}${local.workspace_suffix}"
  vpc_name         = "${local.name}-vpc"
  cluster_name     = "${local.name}-eks"
  route53_zone_id  = data.aws_route53_zone.this.id

  tags = merge(var.tags, {
    "tf:blueprint_root" = local.root
  })

  kubeconfig_file      = "kubeconfig-${module.eks_blueprints.eks_cluster_id}.yaml"
  kubeconfig_file_path = abspath("${path.root}/${local.kubeconfig_file}")

}

#https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.3.2"

  domain_name = var.domain_name
  zone_id     = local.route53_zone_id

  subject_alternative_names = [
    #"new.sub.${var.domain_name}",
    "*.${var.domain_name}"
  ]

}

#https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
#https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
module "vpc" {
  source = "../../modules/aws-vpc-eks"

  name         = local.vpc_name
  cluster_name = local.cluster_name
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.20.0"

  cluster_name    = "${local.name}-eks"
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

#https://www.bitslovers.com/terraform-null-resource/
resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks_blueprints]
  provisioner "local-exec" {
    command = "${module.eks_blueprints.configure_kubectl} --kubeconfig ${local.kubeconfig_file_path}"
  }
}
