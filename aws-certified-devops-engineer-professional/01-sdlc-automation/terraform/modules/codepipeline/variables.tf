variable "pipeline_bucket_name" {
  description = "Bucket name where artifacts are saved after build"
  type = string
}
variable "pipeline_bucket_arn" {
  description = "Bucket arn where artifacts are saved after build"
  type = string
}
variable "codecommit_repo_name" {
  description = "Codecommit repo name for codepipeline source action"
  type = string
}
variable "codebuild_project_name" {
  description = "Codebuild project name for build stage"
  type = string
}