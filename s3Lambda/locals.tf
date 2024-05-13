locals {
  function_name = "s3-event-handler"
  src_path      = "${path.module}/lambda/${local.function_name}"

  binary_name  = local.function_name
  binary_path  = "${path.module}/tf_generated/bootstrap"
  archive_path = "${path.module}/tf_generated/bootstrap.zip"

  tags = {
    Name = "transcoding-app"
  }
}

output "binary_path" {
  value = local.binary_path
}