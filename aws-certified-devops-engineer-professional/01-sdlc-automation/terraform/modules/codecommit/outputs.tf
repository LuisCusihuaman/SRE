output "codecommit_repo_url" {
  value = aws_codecommit_repository.git_repository.clone_url_http
}
output "codecommit_repo_name" {
  value = aws_codecommit_repository.git_repository.repository_name
}