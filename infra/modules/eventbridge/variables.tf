variable "app_name" {
  type = string
}

variable "lambda_arn" {
  type        = string
  description = "ARN da função Lambda alvo do agendamento"
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda (necessário para aws_lambda_permission)"
}
