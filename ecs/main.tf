resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}Ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.project_name}-ecs"
  retention_in_days = 1
}