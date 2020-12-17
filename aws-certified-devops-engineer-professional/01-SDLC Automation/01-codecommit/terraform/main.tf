provider "aws" {
  region = "us-east-1"
}

resource "aws_codecommit_repository" "git_repository" {
  repository_name = "my-webpage"
  description = "This is my webpage repostory for cicd-demo"
}
resource "aws_sns_topic" "git_notification" {
  name = "codecommit-notifications-test-notification"
}
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.git_notification.arn
  policy = data.aws_iam_policy_document.notif_policy_access.json
}
resource "aws_codestarnotifications_notification_rule" "git_codestart_notification_rule" {
  detail_type = "FULL"
  event_type_ids = [
    "codecommit-repository-comments-on-commits",
    "codecommit-repository-comments-on-pull-requests",
    "codecommit-repository-pull-request-source-updated",
    "codecommit-repository-pull-request-created",
    "codecommit-repository-branches-and-tags-created"]
  name = "my-first-notification-rule"
  resource = aws_codecommit_repository.git_repository.arn
  target {
    address = aws_sns_topic.git_notification.arn
  }
}
