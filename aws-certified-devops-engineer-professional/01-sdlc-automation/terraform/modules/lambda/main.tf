variable "lambda_name" {
  type = string
  default = "lambda-codecommit"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create trusted IAM Role for Lambda function to execute by assuming role
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_role.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "${var.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Lambda function
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/lambda_function.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "git_lambda_function" {
  function_name = var.lambda_name
  description = "My awesome lambda function"
  handler = "index.lambda_handler"
  role = aws_iam_role.this.arn
  runtime = "python2.7"
  filename = "${path.module}/index.zip"
  source_code_hash = filebase64sha256("${path.module}/index.zip")
}

# ---------------------------------------------------------------------------------------------------------------------
# Create CloudWatch log group for Lambda log destination
# Lambda function will try to create a log group called /aws/lambda/<function name> if it doesn't exist.
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
# Other Docs: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 30
}

# ---------------------------------------------------------------------------------------------------------------------
# Create and attach IAM policy for Lambda function to write to and create CloudWatch log streams
# Attached a first role created for lambda
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_policy.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "log" {
  statement {
    actions = ["logs:CreateLogGroup"]
    resources = [
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]
    resources = [
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.this.name}:*"
    ]
  }
  statement {
    actions = [
      "codecommit:GetRepository"
    ]
    resources = [
      "arn:aws:codecommit:us-east-1:${data.aws_caller_identity.current.account_id}:my-webpage"
    ]
  }
}

resource "aws_iam_policy" "log" {
  name = "${var.lambda_name}-log-policy"
  policy = data.aws_iam_policy_document.log.json
}

resource "aws_iam_role_policy_attachment" "log" {
  policy_arn = aws_iam_policy.log.arn
  role = aws_iam_role.this.name
}


output "git_lambda_function" {
  value = aws_lambda_function.git_lambda_function
}