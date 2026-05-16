output "stream_name" {
  value = aws_kinesis_stream.main.name
}

output "stream_arn" {
  value = aws_kinesis_stream.main.arn
}
