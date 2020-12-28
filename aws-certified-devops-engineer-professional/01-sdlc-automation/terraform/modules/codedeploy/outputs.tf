output "repo_bucket_artifacts_name" {
  value = aws_s3_bucket.bucket_deploy_revisions.id
}
output "repo_bucket_artifacts_arn" {
  value = aws_s3_bucket.bucket_deploy_revisions.arn
}