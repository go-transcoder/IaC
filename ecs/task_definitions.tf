resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.project_name}-ecs"
  retention_in_days = 1
}

# task definitions
#resource "aws_ecs_task_definition" "task_definitions" {
#
#  for_each = var.task_definitions
#
#  requires_compatibilities = ["FARGATE"]
#  network_mode             = "awsvpc" # awsvpc required for Fargate tasks
#
#  execution_role_arn = aws_iam_role.this.arn
#  task_role_arn      = aws_iam_role.task_role.arn
#
#  cpu    = 1024 # default
#  memory = 4096 # 4 GB default
#
#  container_definitions = jsonencode([
#    {
#      name             = each.key
#      image            = "${each.value.image}:main"
#      environment      = each.value.env
#      logConfiguration = {
#        logDriver = "awslogs"
#        options   = {
#          awslogs-region        = var.region
#          awslogs-group         = "${var.project_name}-ecs"
#          awslogs-stream-prefix = each.key
#        }
#      }
#      portMappings = coalesce(each.value.portMapping, [])
#    }
#  ])
#  family = each.value.family
#}
#
