variable "app_name" {
  type = string
}

variable "sqs_queue_arn" {
  type        = string
  description = "ARN da fila SQS que receberá mensagens do tópico"
}
