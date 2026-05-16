variable "app_name" {
  type = string
}

variable "lambda_invoke_arn" {
  type        = string
  description = "invoke_arn da função Lambda (formato arn:aws:apigateway:...)"
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda (necessário para aws_lambda_permission)"
}
