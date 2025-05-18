#--------------------------------------------------------------
# API Gateway Resources for Snackbar Management
#--------------------------------------------------------------

resource "aws_apigatewayv2_api" "snackbar_management_api" {
  name          = "${data.terraform_remote_state.global.outputs.project_name}-api"
  description   = "Snackbar Management HTTP API Gateway"
  protocol_type = "HTTP"
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-api"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

resource "aws_apigatewayv2_authorizer" "jwt_auth" {
  api_id           = aws_apigatewayv2_api.snackbar_management_api.id
  name             = "lambda-authorizer"
  authorizer_type  = "REQUEST"
  identity_sources = ["$request.header.Authorization"]
  authorizer_uri = data.terraform_remote_state.lambda.outputs.lambda_authorizer_invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
}

resource "aws_cloudwatch_log_group" "snackbar_management_api_log_group" {
  name = "/aws/apigateway/${aws_apigatewayv2_api.snackbar_management_api.name}"
  retention_in_days = 30
  
  tags = {
    Name        = "${data.terraform_remote_state.global.outputs.project_name}-api-logs"
    Project     = data.terraform_remote_state.global.outputs.project_name
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.snackbar_management_api.id
  name   = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.snackbar_management_api_log_group.arn
    format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

#--------------------------------------------------------------
# Health Check Endpoint
#--------------------------------------------------------------

resource "aws_apigatewayv2_integration" "snackbar_management_get_health" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/actuator/health"
}

resource "aws_apigatewayv2_route" "api_route_get_health" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_get_health.id}"
  authorization_type = "NONE"
}

#--------------------------------------------------------------
# IAM Authentication Endpoints
#--------------------------------------------------------------

# User signup endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_post_signup" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "POST"
  integration_uri        = "http://${var.alb_dns_name}/api/user/auth/signup"
}

resource "aws_apigatewayv2_route" "api_route_post_signup" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "POST /signup"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_post_signup.id}"
  authorization_type = "NONE"
}

# User login endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_post_login" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "POST"
  integration_uri        = "http://${var.alb_dns_name}/api/user/auth/login"
}

resource "aws_apigatewayv2_route" "api_route_post_login" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "POST /login"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_post_login.id}"
  authorization_type = "NONE"
}

#--------------------------------------------------------------
# User Management Endpoints
#--------------------------------------------------------------

# Get all users endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_get_users" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/api/user/"
}

resource "aws_apigatewayv2_route" "api_route_get_users" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "GET /user"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_get_users.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Get user by CPF endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_get_user_by_cpf" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/api/user/cpf/{cpf}"
}

resource "aws_apigatewayv2_route" "api_route_get_user_by_cpf" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "GET /user/cpf/{cpf}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_get_user_by_cpf.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Update user endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_put_user" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "PUT"
  integration_uri        = "http://${var.alb_dns_name}/api/user/{id}"
}

resource "aws_apigatewayv2_route" "api_route_put_user" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "PUT /user/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_put_user.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Delete user endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_delete_user" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "DELETE"
  integration_uri        = "http://${var.alb_dns_name}/api/user/{id}"
}

resource "aws_apigatewayv2_route" "api_route_delete_user" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "DELETE /user/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_delete_user.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

#--------------------------------------------------------------
# Product Endpoints
#--------------------------------------------------------------

# Create product endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_post_product" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "POST"
  integration_uri        = "http://${var.alb_dns_name}/api/product"
}

resource "aws_apigatewayv2_route" "api_route_post_product" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "POST /product"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_post_product.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Get all products endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_get_products" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/api/product"
}

resource "aws_apigatewayv2_route" "api_route_get_products" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "GET /product"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_get_products.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Get product by ID endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_get_product_by_id" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/api/product/id/{id}"
}

resource "aws_apigatewayv2_route" "api_route_get_product_by_id" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "GET /product/id/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_get_product_by_id.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Get products by category endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_get_products_by_category" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/api/product/category/{category}"
}

resource "aws_apigatewayv2_route" "api_route_get_products_by_category" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "GET /product/category/{category}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_get_products_by_category.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Get product by name endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_get_product_by_name" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns_name}/api/product/name/{name}"
}

resource "aws_apigatewayv2_route" "api_route_get_product_by_name" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "GET /product/name/{name}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_get_product_by_name.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Update product endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_put_product" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "PUT"
  integration_uri        = "http://${var.alb_dns_name}/api/product/id/{id}"
}

resource "aws_apigatewayv2_route" "api_route_put_product" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "PUT /product/id/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_put_product.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

# Delete product endpoint
resource "aws_apigatewayv2_integration" "snackbar_management_delete_product" {
  api_id                 = aws_apigatewayv2_api.snackbar_management_api.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "DELETE"
  integration_uri        = "http://${var.alb_dns_name}/api/product/id/{id}"
}

resource "aws_apigatewayv2_route" "api_route_delete_product" {
  api_id    = aws_apigatewayv2_api.snackbar_management_api.id
  route_key = "DELETE /product/id/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.snackbar_management_delete_product.id}"
  authorization_type = "CUSTOM"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_auth.id
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.lambda.outputs.aws_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.snackbar_management_api.execution_arn}/*/*"
}
