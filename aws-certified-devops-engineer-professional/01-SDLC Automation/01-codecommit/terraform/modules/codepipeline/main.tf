locals {
  pipeline_name = "CodePipelineDemo"
}
# ---------------------------------------------------------------------------------------------------------------------
# Create IAM Role and inline-policy for Codepipeline service
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
# Other Docs: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "codepipeline" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "codepipeline-${local.pipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline.json
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role_policy" "policy" {
  role = aws_iam_role.this.id
  policy = templatefile("${path.module}/codepipeline_policy.json",
  {
    account_id = data.aws_caller_identity.current.account_id
    codepipeline_name = local.pipeline_name
    codepipeline_bucket_arn = var.pipeline_bucket_arn
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Pipeline for SDLC
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/cloudwatch_log_group.html
# Other Docs: https://docs.aws.amazon.com/lambda/latest/dg/monitoring-cloudwatchlogs.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_codepipeline" "demo_pipeline" {
  name = local.pipeline_name
  role_arn = aws_iam_role.this.arn

  artifact_store {
    type = "S3"
    location = var.pipeline_bucket_name
  }

  stage {
    name = "Source"
    action {
      name = "Source"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = ["source_output"]
      configuration = {
        RepositoryName = var.codecommit_repo_name
        BranchName = "master"
      }
    }
  }
  stage {
    name = "Build"
    action {
      category = "Build"
      name = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      name = "Deploy"
      category = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      input_artifacts = ["build_output"]
      version = "1"
      configuration = {
        ApplicationName = "CodeDeployDemo"
        DeploymentGroupName = "MyDevelopmentInstances"
      }
    }
  }
}


