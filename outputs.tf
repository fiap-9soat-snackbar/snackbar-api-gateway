# API Gateway

output "api_gateway_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_apigatewayv2_api.snackbar_management_api.execution_arn
}

output "api_gateway_api_endpoint" {
  description = "API Gateway API endpoint"
  value       = aws_apigatewayv2_api.snackbar_management_api.api_endpoint
}

output "api_gateway_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.snackbar_management_api.id
}
output "api_gateway_stage_name" {
  description = "Name of the default stage"
  value       = aws_apigatewayv2_stage.default.name
}

output "api_gateway_stage_invoke_url" {
  description = "URL to invoke the API Gateway stage"
  value       = aws_apigatewayv2_stage.default.invoke_url
}