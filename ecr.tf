# OIDC
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["1b511abead59c6ce207077c0bf0e0043b1382612"]
}

# Create the registry for the test image
resource "aws_ecr_repository" "transcoding" {
  provider             = aws.north
  name                 = "${var.project_name}-transcoding"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# Assumed role for the ecr role
data "aws_iam_policy_document" "ecr_assume_role" {
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
      values   = [
        "repo:go-transcoder/transcoder:ref:refs/heads/main",
      ]
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
  name               = "${var.project_name}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecr_assume_role.json
}

# Policy to be added to the role
resource "aws_iam_policy" "access_registry_policy" {
  name        = "${var.project_name}-rest-registry-access"
  description = "Policy to access the ${var.project_name} registries"

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
        Resource : [
          aws_ecr_repository.transcoding.arn,
        ]
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
  policy_arn = aws_iam_policy.access_registry_policy.arn
}
