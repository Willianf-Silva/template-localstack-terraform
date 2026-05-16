variable "app_name" {
  type = string
}

variable "lambda_function_name" {
  type        = string
  description = "Nome da função Lambda para criar o log group e o alarme"
}
