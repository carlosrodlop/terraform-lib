provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

locals {
  cluster_name         = "${var.name}-eks"
  efs_name             = "${var.name}-efs"
  enable_efs           = alltrue([var.enable_efs, length(var.private_subnets_ids) > 0, length(var.azs) > 0, length(var.private_subnets_cidr_blocks) > 0])
  current_region       = data.aws_region.current.name
  current_account_id   = data.aws_caller_identity.current.account_id
  current_account_arn  = data.aws_caller_identity.current.arn
  kubeconfig_file      = "kubeconfig-${module.eks.cluster_name}.yaml"
  kubeconfig_file_path = abspath("${path.root}/${local.kubeconfig_file}")
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3" #Note for EKS Blueprint v5 "~> 19.13"

  cluster_name    = local.cluster_name
  cluster_version = var.k8s_version

  #https://docs.aws.amazon.com/eks/latest/userguide/cluster-endpoint.html
  cluster_endpoint_public_access       = var.k8s_api_public
  cluster_endpoint_private_access      = var.k8s_api_private
  cluster_endpoint_public_access_cidrs = var.ssh_cidr_blocks_k8s

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets_ids

  cluster_addons = var.aws_tf_bp_version == "v4" ? {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  } : {}

  # Security groups based on the best practices doc https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html.
  #   So, by default the security groups are restrictive. Users needs to enable rules for specific ports required for App requirement or Add-ons
  #   See the notes below for each rule used in these examples
  node_security_group_additional_rules = {
    # Recommended outbound traffic for Node groups
    egress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
    # Extend node-to-node security group rules. Recommended and required for the Add-ons
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

  #IMPORTANT: Desired Sized cannot be changed https://github.com/terraform-aws-modules/terraform-aws-eks/issues/835
  #Only Node Groups with Taints can use Autoscaling. Pods requires Selector
  eks_managed_node_groups = {
    #Not scalable for hosting EKS Add-ons. They cannot be tainted
    mg_k8sApps = {
      node_group_name = "managed-k8s-apps"
      instance_types  = var.k8s_instance_types["k8s-apps"]
      capacity_type   = "ON_DEMAND"
      desired_size    = var.k8s_apps_node_size
    },
    #Managed by Autoscaling
    mg_cbApps = {
      node_group_name = "managed-cb-apps"
      instance_types  = var.k8s_instance_types["cb-apps"]
      capacity_type   = "ON_DEMAND"
      create_iam_role = false # Changing `create_iam_role=false` to bring your own IAM Role
      #Alternative using iam_role_additional_policies https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/19.10.2
      iam_role_arn = aws_iam_role.managed_ng.arn
      min_size     = 1
      max_size     = 6
      desired_size = 1
      taints       = [{ key = "dedicated", value = "cb-apps", effect = "NO_SCHEDULE" }]
      labels = {
        ci_type = "cb-apps"
      }
    }
    mg_cbAgents = {
      node_group_name = "managed-agent"
      instance_types  = var.k8s_instance_types["agent"]
      capacity_type   = "ON_DEMAND"
      min_size        = 1
      max_size        = 3
      desired_size    = 1
      taints          = [{ key = "dedicated", value = "build-linux", effect = "NO_SCHEDULE" }]
      labels = {
        ci_type = "build-linux"
      }
    },
    mg_cbAgents_spot = {
      node_group_name = "managed-agent-spot"
      instance_types  = var.k8s_instance_types["agent-spot"]
      capacity_type   = "SPOT"
      min_size        = 1
      max_size        = 3
      desired_size    = 1
      taints          = [{ key = "dedicated", value = "build-linux-spot", effect = "NO_SCHEDULE" }]
      labels = {
        ci_type = "build-linux-spot"
      }
    }
  }

  tags = var.tags
}

#---------------------------------------------------------------
# Custom IAM roles for Node Group Cloudbees Apps
#---------------------------------------------------------------

data "aws_iam_policy_document" "managed_ng_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "managed_ng" {
  name                  = "managed-node-role"
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.managed_ng_assume_role_policy.json
  path                  = "/"
  force_detach_policies = true
  # Mandatory for EKS Managed Node Group
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  # Additional Permissions for for EKS Managed Node Group per https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html
  inline_policy {
    name = "CloudBees_CI"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [ #https://docs.cloudbees.com/docs/cloudbees-ci/latest/backup-restore/cloudbees-backup-plugin#_amazon_s3
          {
            "Sid" : "CBCIBackupPolicy1",
            "Effect" : "Allow",
            "Action" : [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject"
            ],
            "Resource" : "arn:aws:s3:::${var.s3_ci_backup_name}/cbci/*"
          },
          {
            "Sid" : "CBCIBackupPolicy2",
            "Effect" : "Allow",
            "Action" : "s3:ListBucket",
            "Resource" : "arn:aws:s3:::${var.s3_ci_backup_name}"
          },
        ]
      }
    )
  }
  tags = var.tags
}

resource "aws_iam_instance_profile" "managed_ng" {
  name = "managed-node-instance-profile-ci"
  role = aws_iam_role.managed_ng.name
  path = "/"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

#---------------------------------------------------------------
# Storage
#---------------------------------------------------------------

#https://docs.cloudbees.com/docs/cloudbees-common/latest/supported-platforms/cloudbees-ci-cloud#_amazon_elastic_file_system_amazon_efs
module "efs" {
  count   = local.enable_efs ? 1 : 0
  source  = "terraform-aws-modules/efs/aws"
  version = "1.2.0"

  creation_token = local.efs_name
  name           = local.efs_name

  mount_targets = {
    for k, v in zipmap(var.azs, var.private_subnets_ids) : k => { subnet_id = v }
  }
  security_group_description = "${local.efs_name} EFS security group"
  security_group_vpc_id      = var.vpc_id
  #https://d1.awsstatic.com/events/reinvent/2021/Amazon_EFS_performance_best_practices_STG403.pdf
  performance_mode = "generalPurpose"
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = var.private_subnets_cidr_blocks
    }
  }

  tags = var.tags
}

module "ebs_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  description = "Customer managed key to encrypt EKS managed node group volumes"

  # Policy
  key_administrators = [local.current_account_arn]
  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    "arn:aws:iam::${local.current_account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn
  ]

  # Aliases
  aliases = ["eks/${var.name}/ebs"]

  tags = var.tags
}

#---------------------------------------------------------------
# Generating kubeconfig file
#---------------------------------------------------------------

#https://www.bitslovers.com/terraform-null-resource/
resource "null_resource" "create_kubeconfig" {
  triggers = var.kubeconfig_file_update ? {
    always_run = timestamp() #Force to recreate on every apply
  } : {}

  depends_on = [module.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --kubeconfig ${local.kubeconfig_file}"
  }
}
