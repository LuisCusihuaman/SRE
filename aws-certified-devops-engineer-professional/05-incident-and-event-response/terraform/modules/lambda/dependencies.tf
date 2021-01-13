data "aws_iam_policy_document" "WriteToCWLogs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

// ZIP FUNCTIONS
data "archive_file" "DeleteAccessKeyPairZIP" {
  type = "zip"
  output_path = "/tmp/DeleteAccessKeyPairZIP.zip"
  source {
    content = file("${path.module}/functions/delete_access_key_pair.py")
    filename = "delete_access_key_pair.py"
  }
}
data "archive_file" "LookupCloudTrailEventsZIP" {
  type = "zip"
  output_path = "/tmp/LookupCloudTrailEventsZIP.zip"
  source {
    content = file("${path.module}/functions/lookup_cloudtrail_events.py")
    filename = "lookup_cloudtrail_events.py"
  }
}
data "archive_file" "NotifySecurityZIP" {
  type = "zip"
  output_path = "/tmp/NotifySecurityZIP.zip"
  source {
    content = file("${path.module}/functions/notify_security.py")
    filename = "notify_security.py"
  }
}
// INLINE LAMBDA POLICIES
data "aws_iam_policy_document" "DeleteIAMAccessKeyPair" {
  statement {
    effect = "Allow"
    actions = ["iam:DeleteAccessKey", "iam:GetAccessKeyLastUsed"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "LookupCloudTrailEvents" {
  statement {
    effect = "Allow"
    actions = ["cloudtrail:LookupEvents"]
    resources = ["*"]
  }
}


data "aws_iam_policy_document" "PublishToSNSTopic" {
  statement {
    effect = "Allow"
    actions = ["sns:Publish"]
    resources = [var.notification_topic_arn]
  }
}