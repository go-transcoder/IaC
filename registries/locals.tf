locals {
  repository_arns = [for _, repository in aws_ecr_repository.repositories : repository.arn]
}
