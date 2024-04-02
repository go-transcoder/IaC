resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}Ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.tags
}