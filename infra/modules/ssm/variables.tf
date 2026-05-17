variable "app_name" {
  description = "Prefixo da aplicação — usado no caminho dos parâmetros (/{app_name}/config/*)"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente — valor do parâmetro 'env'"
  type        = string
}

variable "log_level" {
  description = "Nível de log padrão da aplicação"
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "log_level deve ser DEBUG, INFO, WARN ou ERROR."
  }
}

variable "extra_parameters" {
  description = "Parâmetros SSM extras além dos padrões (env e log_level). Chave = sufixo do nome, valor = conteúdo"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags aplicadas a todos os parâmetros SSM"
  type        = map(string)
  default     = {}
}
