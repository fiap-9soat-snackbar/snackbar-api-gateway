# snackbar-api-gateway

# API Gateway with JWT Lambda Authorizer

This Terraform configuration provisions an **AWS API Gateway (HTTP API)** integrated with a **Lambda JWT Authorizer** to protect specific routes. The API Gateway routes requests to an Application Load Balancer (ALB) and includes public/unprotected endpoints and authenticated routes requiring JWT validation.

---

## 🚀 Features

- **HTTP API Gateway**: Lightweight, fast, and cost-effective API Gateway for HTTP-based integrations.
- **Lambda JWT Authorizer**: Custom authorizer to validate JWT tokens for protected routes.
- **Public & Protected Routes**:
  - Public routes (`/health`, `/signup`, `/login`) with no authentication.
  - Protected route (`/products`) requiring a valid JWT token.
- **ALB Integration**: Routes requests to backend services via an ALB.
- **CloudWatch Logging**: Access logs for API Gateway requests.
- **Terraform Provisioning**: Infrastructure-as-Code (IaC) for repeatable deployments.

---

## 📐 Architecture

The architecture follows this flow for incoming requests:

1. **Client** → **API Gateway**  
   - Requests are sent to the API Gateway endpoint.
2. **API Gateway** → **Lambda Authorizer** (for protected routes)  
   - For protected routes (e.g., `GET /products`), the API Gateway invokes the Lambda Authorizer to validate the JWT token in the `Authorization` header.
3. **Lambda Authorizer**  
   - Validates the JWT token signature and expiration using a pre-shared secret key.
   - Returns `isAuthorized: true/false` to API Gateway.
4. **API Gateway** → **ALB**  
   - If authorized, the request is forwarded to the ALB (e.g., `http://alb-dns-name/api/productsv2`).

---

## 🛠️ Terraform Resources

| Resource Type                          | Purpose                                                                 |
|----------------------------------------|-------------------------------------------------------------------------|
| `aws_apigatewayv2_api`                 | Creates the HTTP API Gateway.                                          |
| `aws_apigatewayv2_authorizer`          | Configures the Lambda Authorizer for JWT validation.                   |
| `aws_apigatewayv2_integration`         | Defines integration with the ALB for routing requests.                 |
| `aws_apigatewayv2_route`               | Maps routes (e.g., `GET /products`) to integrations.                   |
| `aws_cloudwatch_log_group`             | Stores access logs for API Gateway.                                    |
| `aws_apigatewayv2_stage`               | Deploys the API Gateway stage (`$default`) with logging enabled.       |

---

## 🚀 Deployment

### Prerequisites
1. **AWS CLI Configured** with valid credentials.  
2. **Terraform v1.0+** installed.  
3. **Variables Prepared**:
   - `alb_dns_name` (ALB DNS name from your infrastructure).
   - `lambda_authorizer_invoke_arn` (ARN of your Lambda Authorizer function).

---

## 🛠️ How to Run Terraform

### Plan Infrastructure

Preview changes before applying them (dry-run):
```
terraform plan 
```

### Apply Configuration
Create or update AWS resources:

```
terraform apply
```

### Destroy Resources

```
terraform destroy 
```
