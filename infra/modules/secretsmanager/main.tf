resource "aws_secretsmanager_secret" "app" {
  name = "${var.environment}/${var.app_name}/credentials"
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    api_key     = "local-key-123"
    db_password = "local-password"
  })
}
