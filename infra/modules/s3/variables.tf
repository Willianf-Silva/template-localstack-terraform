variable "app_name" {
  description = "Prefixo da aplicação — usado no nome do bucket"
  type        = string
}

variable "enable_versioning" {
  description = "Habilita versionamento de objetos no bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags aplicadas ao bucket"
  type        = map(string)
  default     = {}
}
