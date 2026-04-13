terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "input" {
  bucket        = var.input_bucket_name
  force_destroy = true
  tags = { Project = "LUIT-Serverless-AI", Environment = var.environment }
}

resource "aws_s3_bucket_versioning" "input" {
  bucket = aws_s3_bucket.input.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket" "output" {
  bucket        = var.output_bucket_name
  force_destroy = true
  tags = { Project = "LUIT-Serverless-AI", Environment = var.environment }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "doc_processor" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  memory_size      = 256
  environment {
    variables = {
      OUTPUT_BUCKET  = aws_s3_bucket.output.bucket
      BEDROCK_MODEL  = var.bedrock_model_id
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    }
  }
  tags = { Project = "LUIT-Serverless-AI", Environment = var.environment }
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.doc_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input.arn
}

resource "aws_s3_bucket_notification" "input_trigger" {
  bucket = aws_s3_bucket.input.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.doc_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".txt"
  }
  lambda_function {
    lambda_function_arn = aws_lambda_function.doc_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".pdf"
  }
  depends_on = [aws_lambda_permission.allow_s3]
}
