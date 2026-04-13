variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "input_bucket_name" {
  description = "S3 bucket for document uploads (must be globally unique)"
  type        = string
  default     = "luit-ai-doc-input-dev"
}

variable "output_bucket_name" {
  description = "S3 bucket for AI summaries (must be globally unique)"
  type        = string
  default     = "luit-ai-doc-output-dev"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "luit-doc-processor"
}

variable "bedrock_model_id" {
  description = "Amazon Bedrock foundation model ID"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}
