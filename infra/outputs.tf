output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}

output "sqs_dlq_url" {
  value = module.sqs.dlq_url
}

output "sns_topic_arn" {
  value = module.sns.topic_arn
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "kms_key_arn" {
  value = module.kms.key_arn
}

output "lambda_function_name" {
  value = module.lambda.function_name
}

output "lambda_function_arn" {
  value = module.lambda.function_arn
}

output "cloudwatch_log_group" {
  value = module.cloudwatch.log_group_name
}

output "kinesis_stream_name" {
  value = module.kinesis.stream_name
}

output "stepfunctions_arn" {
  value = module.stepfunctions.state_machine_arn
}

output "api_gateway_id" {
  value = module.apigateway.api_id
}

output "api_gateway_url" {
  value = module.apigateway.api_url
}
