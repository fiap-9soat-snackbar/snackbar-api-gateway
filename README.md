# API Gateway Module

## 🚀 Features

- HTTP API Gateway (APIGatewayV2) implementation
- JWT-based Lambda authorizer integration
- Authenticated and unauthenticated routes
- CloudWatch logging integration
- ALB backend integration

## 📐 Architecture

The API Gateway module implements an HTTP API (APIGatewayV2) that serves as the primary entry point for the Snackbar application. It includes:

1. HTTP API Gateway with custom domain support
2. Lambda authorizer integration for JWT validation
3. Default stage with auto-deployment
4. CloudWatch logging for API requests
5. Integration with Application Load Balancer backend

## 🔒 Authentication Flow

The API Gateway implements both authenticated and unauthenticated routes:

### Unauthenticated Routes:
- `GET /health` - Health check endpoint
- `POST /signup` - User registration endpoint
- `POST /login` - User authentication endpoint

### Authenticated Routes:
- `GET /products` - Protected products endpoint (requires valid JWT)

## 🛠️ Terraform Resources

The module creates the following AWS resources:

```hcl
- aws_apigatewayv2_api
- aws_apigatewayv2_authorizer
- aws_cloudwatch_log_group
- aws_apigatewayv2_stage
- aws_apigatewayv2_integration (multiple)
- aws_apigatewayv2_route (multiple)
```

## 📝 Variables

| Name | Description | Type |
|------|-------------|------|
| alb_dns_name | ALB DNS name | string |
| bucket | Bucket Tf state | string |

## 📤 Outputs

| Name | Description |
|------|-------------|
| api_gateway_execution_arn | API Gateway execution ARN |
| api_gateway_api_endpoint | API Gateway API endpoint |
| api_gateway_id | API Gateway ID |

## 📋 Usage Example

```hcl
module "api_gateway" {
  source = "./modules/api-gateway"
  
  local_name = "snackbar-dev"
  lambda_authorizer_invoke_arn = module.lambda_authorizer.invoke_arn
  alb_dns_name = module.alb.dns_name
}
```

## 🔄 Integration Details

The API Gateway integrates with backend services through HTTP_PROXY integrations:

### Backend Routes:
- `/actuator/health` - Spring Boot Actuator health endpoint
- `/api/user/auth/signup` - User registration endpoint
- `/api/user/auth/login` - User authentication endpoint
- `/api/productsv2` - Products listing endpoint

All routes are configured with HTTP_PROXY integration type to forward requests directly to the Application Load Balancer.

The API implements a Lambda authorizer for JWT token validation, which is currently enforced on the /products route. This ensures that only authenticated users with valid JWT tokens can access the products endpoint.

### Lambda Authorizer
The API Gateway uses a Lambda authorizer for JWT validation with the following configuration:
- Authorizer type: REQUEST
- Identity source: Request header "Authorization"
- Payload format version: 2.0
- Simple responses enabled

### CloudWatch Logging
API access logs are stored in CloudWatch with:
- Log group name: /aws/apigateway/{api-name}
- Retention period: 30 days
- Log format includes: source IP, timestamp, HTTP method, route, status code, etc.

### Backend Integration
All routes are integrated with the Application Load Balancer using HTTP_PROXY integration type, allowing direct pass-through of requests to the backend services.