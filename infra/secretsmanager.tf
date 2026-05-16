# --- SECRETS MANAGER (GESTÃO DE SENHAS/KEYS) ---
resource "aws_secretsmanager_secret" "app_secrets" {
  name = "dev/app/credentials"
}

resource "aws_secretsmanager_secret_version" "example_val" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    api_key     = "local-key-123",
    db_password = "local-password"
  })
}