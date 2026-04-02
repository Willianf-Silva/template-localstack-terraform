# --- MENSAGERIA (SQS) ---
resource "aws_sqs_queue" "main_queue" {
  name = "app-sqs-queue"
}