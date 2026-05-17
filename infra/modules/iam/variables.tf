variable "app_name" {
  description = "Prefixo da aplicação — usado nos nomes da role e da policy"
  type        = string
}

variable "s3_bucket_arns" {
  description = "Lista de ARNs de buckets S3 que a Lambda pode acessar. Use [\"*\"] para acesso amplo (apenas local)"
  type        = list(string)
  default     = ["*"]
}

variable "sqs_queue_arns" {
  description = "Lista de ARNs de filas SQS que a Lambda pode consumir. Use [\"*\"] para acesso amplo (apenas local)"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags aplicadas à IAM role"
  type        = map(string)
  default     = {}
}
