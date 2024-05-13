output "db_security_group_id" {
  value = module.db_instance_security_group.security_group_id
}

output "ecs_security_group_id" {
  value = module.ecs_task_security_group.security_group_id
}

output "vpc_endpoint_security_group" {
  value = module.vpc_endpoint_security_group.security_group_id
}

output "lb_security_group" {
  value = module.lb_security_group.security_group_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets_cidr_blocks" {
  value = module.vpc.private_subnets_cidr_blocks
}

