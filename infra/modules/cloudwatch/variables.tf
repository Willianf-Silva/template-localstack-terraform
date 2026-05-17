variable "app_name" {
  description = "Prefixo da aplicação — usado nos nomes dos recursos CloudWatch"
  type        = string
}

variable "lambda_function_name" {
  description = "Nome da função Lambda para criar o log group e o alarme"
  type        = string
}

variable "log_retention_in_days" {
  description = "Dias de retenção dos logs no CloudWatch Logs (0 = sem expiração)"
  type        = number
  default     = 7
}

variable "alarm_threshold" {
  description = "Número de erros que dispara o alarme (padrão: qualquer erro)"
  type        = number
  default     = 0
}

variable "alarm_period" {
  description = "Período de avaliação do alarme em segundos"
  type        = number
  default     = 60
}

variable "alarm_evaluation_periods" {
  description = "Número de períodos consecutivos para disparar o alarme"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags aplicadas aos recursos CloudWatch"
  type        = map(string)
  default     = {}
}
