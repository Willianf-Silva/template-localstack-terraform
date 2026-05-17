variable "app_name" {
  description = "Prefixo da aplicação — usado no nome do secret"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente — usado como prefixo no caminho do secret"
  type        = string
}

variable "secret_string" {
  description = "Valor inicial do secret em formato JSON. Sobrescreva em fork para seus dados"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "Tags aplicadas ao secret"
  type        = map(string)
  default     = {}
}
