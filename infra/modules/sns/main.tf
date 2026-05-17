resource "aws_sns_topic" "events" {
  name = "${var.app_name}-events"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "sqs" {
  topic_arn = aws_sns_topic.events.arn
  protocol  = "sqs"
  endpoint  = var.sqs_queue_arn
}
