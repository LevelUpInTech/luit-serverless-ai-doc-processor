output "input_bucket_name" {
  description = "Upload .txt or .pdf documents here to trigger the pipeline"
  value       = aws_s3_bucket.input.bucket
}

output "output_bucket_name" {
  description = "AI-generated summaries are stored here"
  value       = aws_s3_bucket.output.bucket
}

output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.doc_processor.function_name
}

output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function"
  value       = aws_lambda_function.doc_processor.arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group — screenshot this for your challenge proof!"
  value       = "/aws/lambda/${aws_lambda_function.doc_processor.function_name}"
}
