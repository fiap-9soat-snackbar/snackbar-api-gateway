resource "aws_apigatewayv2_api" "snackbar_api" {
  name          = "${data.terraform_remote_state.global.outputs.project_name}-api"
  description   = "Snackbar HTTP API Gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "jwt_auth" {
  api_id           = aws_apigatewayv2_api.snackbar_api.id
  name             = "lambda-authorizer"
  authorizer_type  = "REQUEST"
  identity_sources = ["$request.header.Authorization"]

  authorizer_uri = data.terraform_remote_state.lambda.outputs.lambda_authorizer_invoke_arn

  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}

resource "aws_cloudwatch_log_group" "snackbar_api_log_group" {
  name = "/aws/apigateway/${aws_apigatewayv2_api.snackbar_api.name}"
  retention_in_days = 30
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.snackbar_api.id
  name   = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.snackbar_api_log_group.arn
    format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_apigatewayv2_integration" "snackbar_get_health" {
  api_id                 = aws_apigatewayv2_api.snackbar_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/actuator/health"
}

resource "aws_apigatewayv2_route" "api_route_get_health" {
  api_id    = aws_apigatewayv2_api.snackbar_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_get_health.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_integration" "snackbar_post_signup" {
  api_id                 = aws_apigatewayv2_api.snackbar_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "POST"
  integration_uri        = "http://${var.alb_dns_name}/api/user/auth/signup"
}

resource "aws_apigatewayv2_route" "api_route_post_signup" {
  api_id    = aws_apigatewayv2_api.snackbar_api.id
  route_key = "POST /signup"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_post_signup.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_integration" "snackbar_post_login" {
  api_id                 = aws_apigatewayv2_api.snackbar_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "POST"
  integration_uri        = "http://${var.alb_dns_name}/api/user/auth/login"
}

resource "aws_apigatewayv2_route" "api_route_post_login" {
  api_id    = aws_apigatewayv2_api.snackbar_api.id
  route_key = "POST /login"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_post_login.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_integration" "snackbar_get_products" {
  api_id                 = aws_apigatewayv2_api.snackbar_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/api/productsv2"
}

resource "aws_apigatewayv2_route" "api_route_get_products" {
  api_id    = aws_apigatewayv2_api.snackbar_api.id
  route_key = "GET /products"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_get_products.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambda.outputs.aws_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.snackbar_api.execution_arn}/*/*"
}