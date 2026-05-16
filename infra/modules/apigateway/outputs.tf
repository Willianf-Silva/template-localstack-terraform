output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_url" {
  value = "${var.localstack_endpoint}/restapis/${aws_api_gateway_rest_api.main.id}/local/_user_request_/health"
}
