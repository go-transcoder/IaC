resource "aws_iam_role" "this" {
  name               = "MyECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.execution_role_assume_role_policy.json
}

data "aws_iam_policy_document" "execution_role_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ECSTaskExecutionRoleAccessECR" {
  name        = "ECSTaskExecutionRoleAccessECR"
  description = "Access the Container registry"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ],
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_ecr_policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ECSTaskExecutionRoleAccessECR.arn
}

