#ECR
output "registries" {
  value = module.registries.repository_urls
}

output "github_role_arn" {
  value = module.registries.github_role
}

output "region" {
  description = "AWS region"
  value       = var.region
}

## DB
output "db_endpoint" {
  value = module.db_aurora[0].host_url
}

# ECS
#output "uploader_task_definition" {
#  value = module.ecs.uploader_task_definition
#}

# VPC
output "private_subnets_id" {
  value = module.vpc.private_subnets
}

output "ecs_tasks_security_group" {
  value = module.vpc.ecs_security_group_id
}

# Bastion
output "bastion_public_id" {
  value = module.jump_box.public_ip
}

output "jump_box_private_key" {
  value     = module.jump_box.private_key_pem
  sensitive = true
}


#LB
output "uploader_lb_dns" {
  value = module.lb.upload_app_lb_dns
}