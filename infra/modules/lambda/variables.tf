variable "app_name" {
  type = string
}

variable "role_arn" {
  type        = string
  description = "ARN da IAM role de execução da função"
}
