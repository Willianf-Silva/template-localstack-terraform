variable "app_name" {
  description = "Prefixo da aplicação — usado nos nomes das filas"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Tempo (em segundos) que uma mensagem fica invisível após ser recebida"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Tempo (em segundos) que mensagens ficam retidas na fila (padrão: 4 dias)"
  type        = number
  default     = 345600
}

variable "max_receive_count" {
  description = "Número máximo de recebimentos antes de enviar mensagem para a DLQ"
  type        = number
  default     = 3
}

variable "tags" {
  description = "Tags aplicadas às filas"
  type        = map(string)
  default     = {}
}
