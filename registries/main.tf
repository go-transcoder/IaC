resource "aws_ecr_repository" "repositories" {
  for_each = var.registries_names

  name     = "${var.registries_prefix}_${each.key}"
  provider = var.registries_provider

  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

locals {
  repository_arns = [for _, repository in aws_ecr_repository.repositories : repository.arn]
}

# Assumed role for the ecr role
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.github.arn]
      type        = "Federated"
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.registries_allowed_repos
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [
        "sts.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = var.registries_oidc_role_name
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_policy" "this" {
  name        = "${var.registries_oidc_role_name}-policy"
  description = "Policy to access the project registries"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid : "VisualEditor0",
        Effect : "Allow",
        Action : [
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource : local.repository_arns
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      }
    ],
  })
}