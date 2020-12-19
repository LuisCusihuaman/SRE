provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create trusted IAM Role for CodeBuild project to execute by assuming role
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_role.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "codebuild-${var.codebuild_name}-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild.json
}

# ---------------------------------------------------------------------------------------------------------------------
# Create CloudBuild project with codecommit repository source
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project
# Other Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-environment
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_codebuild_project" "git_project" {
  name = var.codebuild_name
  description = "We will test whether or not index.html"
  service_role = aws_iam_role.this.arn
  source {
    type = "CODECOMMIT"
    location = var.codecommit_repo_url
  }
  source_version = "refs/heads/master"
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type = "LINUX_CONTAINER"
  }
  artifacts {
    type = "NO_ARTIFACTS"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# Create CloudWatch log group for CodeBuild log destination
# Lambda function will try to create a log group called /aws/lambda/<function name> if it doesn't exist.
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
# Other Docs: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.codebuild_name}"
  retention_in_days = 30
}

# ---------------------------------------------------------------------------------------------------------------------
# Create and attach IAM Role policy for CodeBuild to write to and create CloudWatch log streams
# Attached a first role created for lambda
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_policy.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# ---------------------------------------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "policy" {
  role = aws_iam_role.this.name
  name = "${var.codebuild_name}-policy"
  policy = templatefile("${path.module}/codebuild_policy.json",
  {
    account_id = data.aws_caller_identity.current.account_id
    codebuild_name = var.codebuild_name
    codecommit_name = var.codecommit_repo_name
  })
}

