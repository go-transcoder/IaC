## get latest task definition and store it in service Important !
#data "aws_ecs_task_definition" "this" {
#  for_each = aws_ecs_task_definition.task_definitions
#  task_definition = each.value.family
#
#  depends_on = [aws_ecs_task_definition.task_definitions]
#}
#
#resource "aws_ecs_service" "services" {
#  for_each = var.services
#
#  name            = each.key
#  cluster         = aws_ecs_cluster.this.id
#  task_definition = data.aws_ecs_task_definition.this[each.value.task_definition].arn
#
#  launch_type = "FARGATE"
#
#  desired_count = each.value.desired_count
#
#  deployment_maximum_percent         = each.value.deployment_maximum_percent
#  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
#
#  network_configuration {
#    subnets         = each.value.subnets_list
#    security_groups = [each.value.security_group]
#  }
#
#  #  dynamic "load_balancer" {
#  #    for_each = can(index(each.value, "load_balancer")) ? [1] : []
#  #    content {
#  #      target_group_arn = each.value.load_balancer.target_group_arn
#  #      container_name   = each.value.task_definition
#  #      container_port   = each.value.load_balancer.container_port
#  #    }
#  #  }
#
#  dynamic "load_balancer" {
#    for_each = coalesce(each.value.load_balancer, [])
#    content {
#      target_group_arn = load_balancer.value.target_group_arn
#      container_name   = each.value.task_definition
#      container_port   = load_balancer.value.container_port
#    }
#  }
#}