output "s3_bucket_name" {
  value       = var.enable_s3 ? module.s3[0].bucket_name : null
  description = "Nome do bucket S3 criado"
}

output "s3_bucket_arn" {
  value       = var.enable_s3 ? module.s3[0].bucket_arn : null
  description = "ARN do bucket S3"
}

output "sqs_queue_url" {
  value       = var.enable_sqs ? module.sqs[0].queue_url : null
  description = "URL da fila SQS principal"
}

output "sqs_queue_arn" {
  value       = var.enable_sqs ? module.sqs[0].queue_arn : null
  description = "ARN da fila SQS principal"
}

output "sqs_dlq_url" {
  value       = var.enable_sqs ? module.sqs[0].dlq_url : null
  description = "URL da Dead Letter Queue"
}

output "sqs_dlq_arn" {
  value       = var.enable_sqs ? module.sqs[0].dlq_arn : null
  description = "ARN da Dead Letter Queue"
}

output "sns_topic_arn" {
  value       = var.enable_sns ? module.sns[0].topic_arn : null
  description = "ARN do tópico SNS"
}

output "dynamodb_table_name" {
  value       = var.enable_dynamodb ? module.dynamodb[0].table_name : null
  description = "Nome da tabela DynamoDB"
}

output "dynamodb_table_arn" {
  value       = var.enable_dynamodb ? module.dynamodb[0].table_arn : null
  description = "ARN da tabela DynamoDB"
}

output "secretsmanager_secret_arn" {
  value       = var.enable_secretsmanager ? module.secretsmanager[0].secret_arn : null
  description = "ARN do secret no Secrets Manager"
}

output "kms_key_arn" {
  value       = var.enable_kms ? module.kms[0].key_arn : null
  description = "ARN da chave KMS"
}

output "kms_key_id" {
  value       = var.enable_kms ? module.kms[0].key_id : null
  description = "ID da chave KMS"
}

output "iam_lambda_role_arn" {
  value       = var.enable_iam ? module.iam[0].lambda_role_arn : null
  description = "ARN da IAM role de execução da Lambda"
}

output "lambda_function_name" {
  value       = var.enable_lambda ? module.lambda[0].function_name : null
  description = "Nome da função Lambda"
}

output "lambda_function_arn" {
  value       = var.enable_lambda ? module.lambda[0].function_arn : null
  description = "ARN da função Lambda"
}

output "cloudwatch_log_group" {
  value       = var.enable_cloudwatch ? module.cloudwatch[0].log_group_name : null
  description = "Nome do log group da Lambda no CloudWatch"
}

output "cloudwatch_alarm_name" {
  value       = var.enable_cloudwatch ? module.cloudwatch[0].alarm_name : null
  description = "Nome do alarme de erros da Lambda"
}

output "eventbridge_rule_name" {
  value       = var.enable_eventbridge ? module.eventbridge[0].rule_name : null
  description = "Nome da rule de schedule no EventBridge"
}

output "ssm_env_parameter" {
  value       = var.enable_ssm ? module.ssm[0].env_parameter_name : null
  description = "Nome do parâmetro SSM de ambiente"
}

output "ssm_log_level_parameter" {
  value       = var.enable_ssm ? module.ssm[0].log_level_parameter_name : null
  description = "Nome do parâmetro SSM de log level"
}

output "kinesis_stream_name" {
  value       = var.enable_kinesis ? module.kinesis[0].stream_name : null
  description = "Nome do Kinesis Data Stream"
}

output "kinesis_stream_arn" {
  value       = var.enable_kinesis ? module.kinesis[0].stream_arn : null
  description = "ARN do Kinesis Data Stream"
}

output "stepfunctions_arn" {
  value       = var.enable_stepfunctions ? module.stepfunctions[0].state_machine_arn : null
  description = "ARN da State Machine"
}

output "api_gateway_id" {
  value       = var.enable_apigateway ? module.apigateway[0].api_id : null
  description = "ID da REST API no API Gateway"
}

output "api_gateway_url" {
  value       = var.enable_apigateway ? module.apigateway[0].api_url : null
  description = "URL do endpoint /health no API Gateway"
}
