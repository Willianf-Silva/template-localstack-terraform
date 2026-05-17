output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_url" {
  description = "URL completa do endpoint /health no LocalStack"
  value       = "${var.localstack_endpoint}/restapis/${aws_api_gateway_rest_api.main.id}/${var.stage_name}/_user_request_/health"
}
