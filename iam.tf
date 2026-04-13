data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.lambda_function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags = { Project = "LUIT-Serverless-AI", Environment = var.environment }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_s3" {
  statement {
    sid     = "ReadInputBucket"
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.input.arn}/*"]
  }
  statement {
    sid     = "WriteOutputBucket"
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:PutObjectAcl"]
    resources = ["${aws_s3_bucket.output.arn}/*"]
  }
}

resource "aws_iam_role_policy" "lambda_s3_policy" {
  name   = "${var.lambda_function_name}-s3-policy"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_s3.json
}

data "aws_iam_policy_document" "lambda_bedrock" {
  statement {
    sid     = "InvokeBedrockModel"
    effect  = "Allow"
    actions = ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream"]
    resources = ["arn:aws:bedrock:${var.aws_region}::foundation-model/${var.bedrock_model_id}"]
  }
}

resource "aws_iam_role_policy" "lambda_bedrock_policy" {
  name   = "${var.lambda_function_name}-bedrock-policy"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_bedrock.json
}
