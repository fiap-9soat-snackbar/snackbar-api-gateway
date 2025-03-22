# Global variables

variable "local_name" {
  description = "Concatenation of product name, release name and environment"
  type        = string
}

# Lambda variables

variable "lambda_authorizer_invoke_arn" {
  description = "Lambda authorizer invoker ARN"
  type        = string
}

# ALB variables

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}