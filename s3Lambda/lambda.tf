

# build the binary for the lambda function in a specified path
resource "null_resource" "function_binary" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "cd ${local.src_path}; GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -mod=readonly -ldflags='-s -w' -o ../../../${local.binary_path}"
  }
}

# zip the binary, as we can videos only zip files to AWS lambda
data "archive_file" "s3_event_function_archive" {
  depends_on = [null_resource.function_binary]

  type        = "zip"
  source_file = local.binary_path
  output_path = local.archive_path
}


# create the lambda function from zip file
resource "aws_lambda_function" "s3_event_trigger" {
  filename      = local.archive_path
  function_name = local.function_name
  role          = aws_iam_role.this.arn
  handler       = local.binary_name

  source_code_hash = data.archive_file.s3_event_function_archive.output_base64sha256

  runtime = "provided.al2"

  #  environment {
  #    variables = {
  #      QUEUE_URL = aws_sqs_queue.source.url
  #    }
  #  }
}

# resource based policy
resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowS3BucketTrigger"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_trigger.arn
  principal     = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.uploader_bucket.arn # replace 'your_bucket' with your actual S3 bucket name
}
