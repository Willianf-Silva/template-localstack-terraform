resource "aws_sqs_queue" "dlq" {
  name                      = "${var.app_name}-queue-dlq"
  message_retention_seconds = var.message_retention_seconds
  tags                      = var.tags
}

resource "aws_sqs_queue" "main" {
  name                       = "${var.app_name}-queue"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  tags                       = var.tags

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })
}
