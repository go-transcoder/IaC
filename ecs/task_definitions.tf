#resource "aws_cloudwatch_log_group" "this" {
#  name              = "${var.project_name}-ecs"
#  retention_in_days = 1
#}
#
## check if repository exists first to get latest image
#
#data "aws_ecr_image" "this" {
#  for_each = var.task_definitions
#
#  repository_name = each.value.repository_name
#  image_tag       = "latest"
#}
#
## if we have images then get latest image
## Terraform's AWS provider does not provide a mechanism to query the ecr repository.
##
## We use an external data source, which can run any program that returns valid JSON, to run the AWS
## cli manually, which will produce a JSON in the following format:
##
##   {
##     "tags": "[\"1.0.0.1166\"]"
##   }
##
#data "external" "tags_of_most_recently_pushed_image" {
#  for_each = { for image in data.aws_ecr_image.this : image.repository_name => image }
#
#  program = [
#    "aws", "ecr", "describe-images",
#    "--repository-name", each.key,
#    "--query", "{\"tags\": to_string(sort_by(imageDetails,& imagePushedAt)[-1].imageTags)}",
#    "--region", "eu-north-1"
#  ]
#}
#
## task definitions
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
#      image            = "${each.value.image}:${data.aws_ecr_image.this[each.key].count ? jsondecode(data.external.tags_of_most_recently_pushed_image[each.value.repository_name])[0] : "main"}"
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
