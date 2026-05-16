resource "aws_ssm_parameter" "env" {
  name  = "/${var.app_name}/config/env"
  type  = "String"
  value = var.environment
}

resource "aws_ssm_parameter" "log_level" {
  name  = "/${var.app_name}/config/log_level"
  type  = "String"
  value = "INFO"
}
