resource "aws_kinesis_stream" "main" {
  name             = "${var.app_name}-stream"
  shard_count      = var.shard_count
  retention_period = var.retention_period
  tags             = var.tags
}
