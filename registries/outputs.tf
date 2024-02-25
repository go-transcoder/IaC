
output "transcoder_repo_url" {
  value = data.aws_ecr_repository.transcoder_repo.repository_url
}

output "uploader_repo_url" {
  value = data.aws_ecr_repository.uploader_repo.repository_url
}
