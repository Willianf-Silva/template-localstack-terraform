locals {
  default_secret = jsonencode({
    api_key     = "local-key-123"
    db_password = "local-password"
  })
  resolved_secret = var.secret_string != "" ? var.secret_string : local.default_secret
}

resource "aws_secretsmanager_secret" "app" {
  name = "${var.environment}/${var.app_name}/credentials"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = local.resolved_secret
}
