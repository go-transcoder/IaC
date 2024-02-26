# create a role to be assumed by our lambda function

# assume role policy
data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# role
resource "aws_iam_role" "this" {
  name               = var.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.this.json
}

# adding policies to the role
# policy to read from s3 bucket
resource "aws_iam_policy" "this" {
  name        = "read_from_s3"
  description = "read objects from s3 bucket"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.lambda_policy_statements
  })
}

# attache policies to role
resource "aws_iam_role_policy_attachment" "attache_lambda_s3_bucket_trigger_policies" {
  policy_arn = aws_iam_policy.this.arn
  role       = aws_iam_role.this.name
}
