locals {
  repository_arns = [for _, repository in data.aws_ecr_repository.repositories : repository.arn]
}
