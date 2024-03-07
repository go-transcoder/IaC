locals {
  cluster_name = "education-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.27"

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.vpc_subnets
  control_plane_subnet_ids       = var.vpc_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = var.node_groups


  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true


#  # install eks managed addons
#  # more details are here - https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html
#  cluster_addons = {
#    # extensible DNS server that can serve as the Kubernetes cluster DNS
#    coredns = {
#      preserve    = true
#      most_recent = true
#    }
#
#    # maintains network rules on each Amazon EC2 node. It enables network communication to your Pods
#    kube-proxy = {
#      most_recent = true
#    }
#
#    # a Kubernetes container network interface (CNI) plugin that provides native VPC networking for your cluster
#    vpc-cni = {
#      most_recent = true
#    }
#  }
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


resource "aws_iam_policy" "read_write_s3" {
  name        = "read_access_s3"
  description = "read objects from s3 bucket"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:HeadObject",
          "s3:PutObject",
        ],
        Resource = "arn:aws:s3:::*/*",
      }
    ]
  })
}

// creating the EKS Identity Provider Configuration
resource "aws_eks_identity_provider_config" "this" {
  cluster_name = module.eks.cluster_name

  oidc {
    client_id                     = "sts.amazonaws.com"
    identity_provider_config_name = "${module.eks.cluster_name}IdentityProvider"
    issuer_url                    = module.eks.cluster_oidc_issuer_url
  }
}

module "iam_eks_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  role_name = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"

  role_policy_arns = {
    ebs_csi_policy = data.aws_iam_policy.ebs_csi_policy.arn
    s3_policy      = aws_iam_policy.read_write_s3.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:${var.service_account}"]
    }
  }

}

#module "irsa-ebs-csi" {
#  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#  version = "4.7.0"
#
#  create_role                    = true
#  role_name                      = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
#  provider_url                   = module.eks.oidc_provider
#  role_policy_arns               = [data.aws_iam_policy.ebs_csi_policy.arn, aws_iam_policy.read_write_s3.arn]
#  oidc_fully_qualified_subjects  = var.oidc_fully_qualified_subjects
#  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
#}
