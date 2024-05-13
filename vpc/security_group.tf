module "vpc_endpoint_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-vpc-endpoint"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule = "https-443-tcp"
      description = "HTTPS from VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  ingress_with_self = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Container to VPC endpoint service"
      self        = true
    },
  ]


  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-tcp"]
}

module "db_instance_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-db-sg"
  description = "Security group for the database instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      description = "ssh from anywhere"
      cidr_blocks = "0.0.0.0/0"
    }

  ]
  ingress_with_source_security_group_id = [
    {
      rule        = "postgresql-tcp"
      description = "postgresql"
      source_security_group_id = module.ecs_task_security_group.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "out to all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ecs_task_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-ecs-task-sg"
  description = "Security group for the ecs tasks, should be able to reach "
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "in from anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      description = "out to all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-lb-sg"
  description = "Security group for the load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

