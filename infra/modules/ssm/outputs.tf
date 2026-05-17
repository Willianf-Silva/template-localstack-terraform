output "parameter_names" {
  description = "Mapa de todos os parâmetros SSM criados {sufixo: nome_completo}"
  value       = { for k, v in aws_ssm_parameter.params : k => v.name }
}

output "env_parameter_name" {
  description = "Nome completo do parâmetro de ambiente (compatibilidade)"
  value       = aws_ssm_parameter.params["env"].name
}

output "log_level_parameter_name" {
  description = "Nome completo do parâmetro de log level (compatibilidade)"
  value       = aws_ssm_parameter.params["log_level"].name
}
