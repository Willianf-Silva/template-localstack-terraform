resource "aws_kms_key" "main" {
  description             = "Chave KMS para ${var.app_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "main" {
  name          = "alias/${var.app_name}-key"
  target_key_id = aws_kms_key.main.key_id
}
