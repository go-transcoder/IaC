#ECR
#output "transcoder_repo_url" {
#  value = module.registries.transcoder_repo_url
#}
#
#output "uploader_repo_url" {
#  value = module.registries.uploader_repo_url
#}

output "github_role_arn" {
  value = module.registries.github_role
}

#output "cluster_endpoint" {
#  description = "Endpoint for EKS control plane"
#  value       = module.eks.cluster_endpoint
#}
#
#output "cluster_security_group_id" {
#  description = "Security group ids attached to the cluster control plane"
#  value       = module.eks.cluster_security_group_id
#}

output "region" {
  description = "AWS region"
  value       = var.region
}

#output "cluster_name" {
#  description = "Kubernetes Cluster Name"
#  value       = module.eks.cluster_name
#}
#
#output "iam_eks_role_arn" {
#  value = module.eks.iam_eks_role_arn
#}

## DB
output "db_private_key_content" {
  value     = module.db.private_key_pem
  sensitive = true
}

output "db_public_ip" {
  value = module.db.public_ip
}

# Ecr
output "ecr_registries_urls" {
  value = module.registries.repository_urls
}