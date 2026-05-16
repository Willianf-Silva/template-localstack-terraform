resource "aws_sqs_queue" "dlq" {
  name = "${var.app_name}-queue-dlq"
}

resource "aws_sqs_queue" "main" {
  name = "${var.app_name}-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}
