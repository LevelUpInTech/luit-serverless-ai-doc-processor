variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# TODO: Choose a unique name for your S3 input bucket (must be globally unique across all of AWS)
variable "input_bucket_name" {
  description = "Name of the S3 bucket that will trigger Lambda when a document is uploaded"
  type        = string
  # default   = "your-unique-input-bucket-name"   # <-- uncomment and set your own name
}

# TODO: Choose a unique name for your S3 output bucket (must be globally unique across all of AWS)
variable "output_bucket_name" {
  description = "Name of the S3 bucket where AI summaries will be stored"
  type        = string
  # default   = "your-unique-output-bucket-name"  # <-- uncomment and set your own name
}

# TODO: Give your Lambda function a name (must be unique in your AWS account + region)
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  # default   = "your-doc-processor-function"     # <-- uncomment and set your own name
}

variable "bedrock_model_id" {
  description = "Amazon Bedrock foundation model ID to use for summarization"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}
