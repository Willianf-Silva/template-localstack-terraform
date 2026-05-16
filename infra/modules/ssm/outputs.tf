output "env_parameter_name" {
  value = aws_ssm_parameter.env.name
}

output "log_level_parameter_name" {
  value = aws_ssm_parameter.log_level.name
}
