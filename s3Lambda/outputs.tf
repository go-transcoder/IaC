output "s3_bucket" {
  value = aws_s3_bucket.uploader_bucket.bucket
}

output "role_arn" {
  value = aws_iam_role.this.arn
}