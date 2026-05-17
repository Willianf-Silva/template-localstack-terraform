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

variable "localstack_endpoint" {
  description = "URL base do LocalStack (permite apontar para outro host, ex: container em rede Docker)"
  type        = string
  default     = "http://localhost:4566"
}



# --- Feature flags — comente o módulo em main.tf para desativar ---

variable "enable_s3" {
  description = "Habilita o módulo S3"
  type        = bool
  default     = true
}

variable "enable_sqs" {
  description = "Habilita o módulo SQS (necessário para SNS com subscription SQS)"
  type        = bool
  default     = true
}

variable "enable_sns" {
  description = "Habilita o módulo SNS — requer enable_sqs = true"
  type        = bool
  default     = true
}

variable "enable_dynamodb" {
  description = "Habilita o módulo DynamoDB"
  type        = bool
  default     = true
}

variable "enable_secretsmanager" {
  description = "Habilita o módulo Secrets Manager"
  type        = bool
  default     = true
}

variable "enable_kms" {
  description = "Habilita o módulo KMS"
  type        = bool
  default     = true
}

variable "enable_iam" {
  description = "Habilita o módulo IAM (necessário para Lambda)"
  type        = bool
  default     = true
}

variable "enable_lambda" {
  description = "Habilita o módulo Lambda — requer enable_iam = true"
  type        = bool
  default     = true
}

variable "enable_cloudwatch" {
  description = "Habilita o módulo CloudWatch — requer enable_lambda = true"
  type        = bool
  default     = true
}

variable "enable_eventbridge" {
  description = "Habilita o módulo EventBridge — requer enable_lambda = true"
  type        = bool
  default     = true
}

variable "enable_ssm" {
  description = "Habilita o módulo SSM Parameter Store"
  type        = bool
  default     = true
}

variable "enable_kinesis" {
  description = "Habilita o módulo Kinesis"
  type        = bool
  default     = true
}

variable "enable_stepfunctions" {
  description = "Habilita o módulo Step Functions"
  type        = bool
  default     = true
}

variable "enable_apigateway" {
  description = "Habilita o módulo API Gateway — requer enable_lambda = true"
  type        = bool
  default     = true
}
