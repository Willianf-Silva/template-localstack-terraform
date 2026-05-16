resource "aws_kinesis_stream" "main" {
  name             = "${var.app_name}-stream"
  shard_count      = 1
  retention_period = 24
}
