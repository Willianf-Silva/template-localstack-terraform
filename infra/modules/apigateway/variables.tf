variable "app_name" {
  description = "Prefixo da aplicação — usado no nome da API"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "invoke_arn da função Lambda (formato arn:aws:apigateway:...)"
  type        = string
}

variable "lambda_function_name" {
  description = "Nome da função Lambda (necessário para aws_lambda_permission)"
  type        = string
}

variable "stage_name" {
  description = "Nome do stage de deploy da API Gateway"
  type        = string
  default     = "local"
}

variable "localstack_endpoint" {
  description = "URL base do LocalStack — usada para construir a URL do endpoint no output"
  type        = string
  default     = "http://localhost:4566"
}

variable "tags" {
  description = "Tags aplicadas à REST API"
  type        = map(string)
  default     = {}
}
