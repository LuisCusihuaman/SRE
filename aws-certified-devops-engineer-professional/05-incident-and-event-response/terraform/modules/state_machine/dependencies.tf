data "aws_region" "current" {}
data "aws_iam_policy_document" "StatesExecutionPolicy" {
  statement {
    effect = "Allow"
    actions = ["lambda:InvokeFunction"]
    resources = [
      var.delete_access_key_arn,
      var.lookup_cloudtrail_arn,
      var.notify_security_arn
    ]
  }
}