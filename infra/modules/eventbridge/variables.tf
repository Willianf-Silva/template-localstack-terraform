variable "app_name" {
  description = "Prefixo da aplicação — usado no nome da rule"
  type        = string
}

variable "lambda_arn" {
  description = "ARN da função Lambda alvo do agendamento"
  type        = string
}

variable "lambda_function_name" {
  description = "Nome da função Lambda (necessário para aws_lambda_permission)"
  type        = string
}

variable "schedule_expression" {
  description = "Expressão de agendamento do EventBridge (rate ou cron)"
  type        = string
  default     = "rate(5 minutes)"
}

variable "tags" {
  description = "Tags aplicadas à rule do EventBridge"
  type        = map(string)
  default     = {}
}
