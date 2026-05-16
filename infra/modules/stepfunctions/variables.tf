variable "app_name" {
  type = string
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN da IAM role usada pela state machine"
}
