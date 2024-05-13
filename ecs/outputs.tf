#output "uploader_task_definition" {
#  value = aws_ecs_task_definition.task_definitions["uploader"].arn
#}

output "task_execution_role" {
  value = aws_iam_role.this.arn
}

output "task_role" {
  value = aws_iam_role.task_role.arn
}

output "cluster" {
  value = aws_ecs_cluster.this.name
}