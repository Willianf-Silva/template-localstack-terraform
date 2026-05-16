output "log_group_name" {
  value = aws_cloudwatch_log_group.lambda.name
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.lambda_errors.alarm_name
}
