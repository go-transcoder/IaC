resource "aws_iam_role" "task_role" {
  name               = "MyECSTaskERole"
  assume_role_policy = data.aws_iam_policy_document.role_assume_role_policy.json
}

data "aws_iam_policy_document" "role_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ECSTaskRoleAccessECR" {
  name        = "ECSTaskRoleAccessECR"
  description = "Access the Container registry"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
        ],
        Resource = "arn:aws:s3:::*/*",
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ecr_policy" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.ECSTaskRoleAccessECR.arn
}

