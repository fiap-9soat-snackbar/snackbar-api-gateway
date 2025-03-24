terraform {
  backend "s3" {
    region = "us-east-1"
    key    = "api-gateway/terraform.tfstate"
  }
}

data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "global/terraform.tfstate"
  }
}

data "terraform_remote_state" "lambda" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = var.bucket
    key    = "functions/lambda/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}