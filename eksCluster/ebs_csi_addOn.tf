
#resource "aws_eks_addon" "ebs-csi" {
#  cluster_name             = module.eks.cluster_name
#  addon_name               = "aws-ebs-csi-driver"
#  addon_version            = "v1.20.0-eksbuild.1"
#  service_account_role_arn = module.iam_eks_role.iam_role_arn
#  tags                     = {
#    "eks_addon" = "ebs-csi"
#    "terraform" = "true"
#  }
#}