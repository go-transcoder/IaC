// ##############################
// Execution Role ###############
// ##############################

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "BatchECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.batch_execution_role_assume_role_policy.json
}

data "aws_iam_policy_document" "batch_execution_role_assume_role_policy" {
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
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# attach the permissions to get access the s3
resource "aws_iam_role_policy_attachment" "add_s3_access_to_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.s3_role_permissions.arn
}
