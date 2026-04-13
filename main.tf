terraform {
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

# ── S3 Buckets ──────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "input" {
  bucket = var.input_bucket_name
}

resource "aws_s3_bucket" "output" {
  bucket = var.output_bucket_name
}

# ── Lambda Package (zip) ─────────────────────────────────────────────────────

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda_function.zip"
}

# ── Lambda Function ───────────────────────────────────────────────────────────

resource "aws_lambda_function" "doc_processor" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60

  environment {
    variables = {
      OUTPUT_BUCKET    = var.output_bucket_name
      BEDROCK_MODEL_ID = var.bedrock_model_id
    }
  }
}

# ── CloudWatch Log Group ──────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}

# ─────────────────────────────────────────────────────────────────────────────
# TODO #1: Add an aws_lambda_permission resource that allows S3 to invoke
#          your Lambda function.
#
#   Hints:
#     - action        = "lambda:InvokeFunction"
#     - principal     = "s3.amazonaws.com"
#     - source_arn    = aws_s3_bucket.input.arn
#
# resource "aws_lambda_permission" "allow_s3" { ... }
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# TODO #2: Add an aws_s3_bucket_notification resource that triggers your
#          Lambda function whenever an object is created in the input bucket.
#
#   Hints:
#     - bucket       = aws_s3_bucket.input.id
#     - events       = ["s3:ObjectCreated:*"]
#     - lambda_function_arn = aws_lambda_function.doc_processor.arn
#     - depends_on   = [aws_lambda_permission.allow_s3]
#
# resource "aws_s3_bucket_notification" "trigger" { ... }
# ─────────────────────────────────────────────────────────────────────────────
