# API Gateway

output "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_apigatewayv2_api.snackbar_api.execution_arn
}

output "api_gateway_api_endpoint" {
  description = "API Gateway API endpoint"
  value       = aws_apigatewayv2_api.snackbar_api.api_endpoint
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.snackbar_api.id
}