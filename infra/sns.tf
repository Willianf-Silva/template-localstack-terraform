# --- MENSAGERIA (SNS) ---
resource "aws_sns_topic" "app_events" {
  name = "app-events-topic"
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.app_events.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.main_queue.arn
}