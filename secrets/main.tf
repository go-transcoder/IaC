resource "aws_secretsmanager_secret" "this" {
  for_each                = var.secrets
  name                    = each.key
  recovery_window_in_days = 0
  tags                    = local.tags
}

resource "aws_secretsmanager_secret_version" "service_user" {
  for_each      = aws_secretsmanager_secret.this
  secret_id     = each.value.id
  secret_string = var.secrets[each.value.name]
}