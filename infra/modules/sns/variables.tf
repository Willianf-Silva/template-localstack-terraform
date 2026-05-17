variable "app_name" {
  description = "Prefixo da aplicação — usado no nome do tópico"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN da fila SQS que receberá mensagens do tópico"
  type        = string
}

variable "tags" {
  description = "Tags aplicadas ao tópico SNS"
  type        = map(string)
  default     = {}
}
