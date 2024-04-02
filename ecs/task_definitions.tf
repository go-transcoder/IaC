resource "aws_cloudwatch_log_group" "this" {
  name              = "${var.project_name}-ecs"
  retention_in_days = 1
}

module "ecs-fargate-task-definition" {
  source      = "cn-terraform/ecs-fargate-task-definition/aws"
  version     = "1.0.36"

  for_each = var.task_definitions

  name_prefix = var.project_name

  tags = local.tags

  container_cpu    = 1024 # default
  container_image  = "${each.value.image}:${each.value.tag}"
  container_memory = 4096 # 4 GB default
  container_name   = each.key
  docker_labels    = null
  entrypoint       = null

#  repository_credentials = {
#    credentialsParameter : aws_secretsmanager_secret.docker_registry.arn
#  }

  log_configuration = {
    logDriver = "awslogs"
    options   = {
      awslogs-region        = var.region
      awslogs-group         = "${var.project_name}-ecs"
      awslogs-stream-prefix = each.key
    }
  }

  # adding the read secret policy to the task_execution_role
  ecs_task_execution_role_custom_policies = [
    jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          "Action" : [
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetAuthorizationToken"
          ],
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  ]

  # execution_role_arn and task_role_arn by default use the AmazonECSTaskExecutionRolePolicy role

  environment = each.value.env
}

