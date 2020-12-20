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
}
module "lambda" {
  source = "../lambda"
}
module "codedeploy" {
  source = "../codedeploy"
}