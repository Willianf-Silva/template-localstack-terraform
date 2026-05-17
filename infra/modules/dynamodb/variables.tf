variable "app_name" {
  description = "Prefixo da aplicação — usado no nome da tabela"
  type        = string
}

variable "sort_key" {
  description = "Nome do atributo de sort key (range key). Deixe vazio para usar apenas hash key"
  type        = string
  default     = ""
}

variable "sort_key_type" {
  description = "Tipo do sort key: S (String), N (Number) ou B (Binary)"
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.sort_key_type)
    error_message = "sort_key_type deve ser S, N ou B."
  }
}

variable "ttl_attribute" {
  description = "Nome do atributo de TTL. Deixe vazio para desabilitar TTL"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags aplicadas à tabela DynamoDB"
  type        = map(string)
  default     = {}
}
