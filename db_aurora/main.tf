data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "14.5"
}

module "db-aurora" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name              = "${var.project_name}-postgresqlv2"
  engine            = data.aws_rds_engine_version.postgresql.engine
  engine_mode       = "provisioned"
  engine_version    = data.aws_rds_engine_version.postgresql.version
  storage_encrypted = true

  master_username             = var.db_username
  master_password             = var.db_password
  manage_master_user_password = false

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.subnet_group_name
  security_group_rules = var.security_group_rules

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 10
  }

  instance_class = "db.serverless"
  instances      = {
    one = {}
    #    two = {}
  }

  tags = local.tags
}

