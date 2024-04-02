
output "repository_urls" {
  value = { for key, repository in data.aws_ecr_repository.repositories : key => repository.repository_url }
}

output "github_role" {
  value = aws_iam_role.ecs_instance_role.arn
}