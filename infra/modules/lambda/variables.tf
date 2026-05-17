variable "app_name" {
  description = "Prefixo da aplicação — usado no nome da função"
  type        = string
}

variable "role_arn" {
  description = "ARN da IAM role de execução da função"
  type        = string
}

variable "memory_size" {
  description = "Memória alocada para a função Lambda (em MB)"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout máximo da função Lambda (em segundos)"
  type        = number
  default     = 30
}

variable "environment_variables" {
  description = "Variáveis de ambiente extras injetadas na função. APP_NAME é sempre injetado automaticamente"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags aplicadas à função Lambda"
  type        = map(string)
  default     = {}
}
