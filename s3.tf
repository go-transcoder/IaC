resource "aws_s3_bucket" "uploader_bucket" {
  bucket        = "abboud131231231231namir-uploader-bucket"
  force_destroy = true
  tags          = {
    Name = "uploader"
  }
}

# Notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploader_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_event_trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
  }

  depends_on = [aws_lambda_permission.allow_s3_trigger]

}
