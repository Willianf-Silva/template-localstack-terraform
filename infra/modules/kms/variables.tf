variable "app_name" {
  description = "Prefixo da aplicação — usado no alias da chave"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Dias até a exclusão permanente da chave após agendamento de exclusão (mínimo 7)"
  type        = number
  default     = 7

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days deve estar entre 7 e 30."
  }
}

variable "tags" {
  description = "Tags aplicadas à chave KMS"
  type        = map(string)
  default     = {}
}
