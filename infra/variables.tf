variable "app_name" {
  description = "Nome da aplicação — usado como prefixo em todos os recursos"
  type        = string
  default     = "myapp"
}

variable "region" {
  description = "Região AWS (usada apenas no provider)"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nome do ambiente (local, dev, staging)"
  type        = string
  default     = "local"
}
