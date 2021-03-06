variable "codecommit_repo_url" {
  description = "CodeBuild target project url"
  type = string
}
variable "codecommit_repo_name" {
  description = "CodeCommit repository name"
  type = string
}

// Optional
variable "codebuild_name" {
  type = string
  default = "MyWebAppCodeBuildMaster"
}
variable "pipeline_bucket_arn" {
  description = "Bucket arn where artifacts are saved after build"
  type = string
}