# Sample AWS Infrastructure for Infra Reconciler Demo

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Lambda Function
resource "aws_lambda_function" "api" {
  function_name = "sample-api"
  runtime       = "python3.9"  # DEPRECATED as of Dec 15, 2025!
  handler       = "index.handler"
  role          = aws_iam_role.lambda.arn
  filename      = "lambda.zip"
  
  memory_size = 512  # Max is 10240 MB
  timeout     = 30
  
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.data.id
    }
  }
}

# S3 Bucket
resource "aws_s3_bucket" "data" {
  bucket_prefix = "sample-data-"
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "sample-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Outputs
output "lambda_function_name" {
  value = aws_lambda_function.api.function_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.data.id
}
