provider "aws" {
  region = "us-east-1"
}

module "codecommit" {
  source = "../codecommit"
}

module "codebuild" {
  source = "../codebuild"
  codecommit_repo_name = module.codecommit.codecommit_repo_name
  codecommit_repo_url = module.codecommit.codecommit_repo_url
  pipeline_bucket_arn = module.codedeploy.repo_bucket_artifacts_arn
}
//module "lambda" {
//  source = "../lambda"
//}

module "codedeploy" {
  source = "../codedeploy"
}

module "codepipeline" {
  source = "../codepipeline"
  codebuild_project_name = module.codebuild.codebuild_project_name
  codecommit_repo_name = module.codecommit.codecommit_repo_name
  pipeline_bucket_name = module.codedeploy.repo_bucket_artifacts_name
  pipeline_bucket_arn = module.codedeploy.repo_bucket_artifacts_arn
}