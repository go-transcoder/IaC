output "db_security_group_id" {
  value = module.db_instance_security_group.security_group_id
}

output "ecs_security_group_id" {
  value = module.ecs_task_security_group.security_group_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
