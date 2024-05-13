variable "bucket_name" {
  description = "The bucket name that is gonna be used with the transcoder"
  type        = string
  default     = null
}

variable "lambda_policy_statements" {
  description = "The lambda permission statements"
  type        = any
  default     = [
    {
      Effect = "Allow",
      Action = [
        "s3:GetObject",
        "s3:HeadObject"
      ],
      Resource = "arn:aws:s3:::*/*",
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "logs:PutLogEvents",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
      ],
      "Resource" : "arn:aws:logs:*:*:*"
    },
    {
      "Effect" : "Allow",
      "Action" : [
        "batch:SubmitJob",
        "batch:DescribeJobs",
        "batch:TerminateJob"
      ],
      "Resource" : "*"
    },
  ]
}

variable "lambda_role_name" {
  description = "The role that is consumed by the lambda, which let it access the bucket and trigger the batch"
  default     = "ReadFromS3BatchStartJobLogs"
}