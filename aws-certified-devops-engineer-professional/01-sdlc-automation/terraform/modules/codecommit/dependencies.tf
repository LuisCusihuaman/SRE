data "aws_iam_policy_document" "notif_policy_access" {
  statement {
    actions = ["sns:Publish"]
    principals {
      type = "Service"
      identifiers = ["codestar-notifications.amazonaws.com"]
    }
    resources = [aws_sns_topic.git_notification.arn]
  }
}