output "api_id" {
  value = aws_api_gateway_rest_api.main.id
}

output "api_url" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.main.id}/local/_user_request_/health"
}
