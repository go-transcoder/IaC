data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_instance_role" {
  name               = "ec2_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.s3_role_permissions.arn
}

resource "aws_iam_instance_profile" "ec2_instance_role" {
  name = "ec2_instance_role"
  role = aws_iam_role.ec2_instance_role.name
}


resource "aws_iam_policy" "s3_role_permissions" {
  name        = "ecs_read_from_s3"
  description = "read objects from s3 bucket"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:HeadObject",
          "s3:PutObject",
        ],
        Resource = "arn:aws:s3:::*/*",
      }
    ],
  })
}
