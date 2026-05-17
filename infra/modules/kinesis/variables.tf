variable "app_name" {
  description = "Prefixo da aplicação — usado no nome do stream"
  type        = string
}

variable "shard_count" {
  description = "Número de shards do Kinesis Data Stream"
  type        = number
  default     = 1
}

variable "retention_period" {
  description = "Horas de retenção dos dados no stream (mínimo 24h)"
  type        = number
  default     = 24

  validation {
    condition     = var.retention_period >= 24
    error_message = "retention_period deve ser no mínimo 24 horas."
  }
}

variable "tags" {
  description = "Tags aplicadas ao Kinesis Stream"
  type        = map(string)
  default     = {}
}
