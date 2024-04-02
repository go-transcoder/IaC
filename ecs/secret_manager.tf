## TODO: add the secrets for the docker registry
##   https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
#resource "aws_secretsmanager_secret" "docker_registry" {
#  name = "DockerRegistry/Credentials"  # Replace with your desired secret name
#}
#
#resource "aws_secretsmanager_secret_version" "dr_version" {
#  secret_id     = aws_secretsmanager_secret.docker_registry.id
#  secret_string = jsonencode({
#    username = var.registry_username,
#    password = var.registry_password,
#  })
#}