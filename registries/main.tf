provider "aws" {
  # This provider configuration will use the provider passed from the parent module
  region = var.aws_region
  profile = coalesce(var.aws_profile, "default")
}

resource "aws_ecr_repository" "repositories" {
  for_each = toset(concat([var.transcoder_registry_name], [var.uploader_registry_name]))

  name = "${var.registries_prefix}_${each.key}"

  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

data "aws_ecr_repository" "transcoder_repo" {
  depends_on = [aws_ecr_repository.repositories]
  name = "${var.registries_prefix}_${var.transcoder_registry_name}"
}

data "aws_ecr_repository" "uploader_repo" {
  depends_on = [aws_ecr_repository.repositories]
  name = "${var.registries_prefix}_${var.uploader_registry_name}"
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
  name               = "${var.registries_prefix}GithubAceessReposRole"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_policy" "this" {
  name        = "${var.registries_prefix}GithubAceessReposRolePolicy"
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

resource "aws_iam_role_policy_attachment" "github_role_registry_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.this.arn
}