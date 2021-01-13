locals {
  TRUSTED_POLICY = <<TRUSTED
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal":{
        "Service":"lambda.amazonaws.com"
      },
      "Action":"sts:AssumeRole"
    }
  ]
}
  TRUSTED
}

resource "aws_iam_policy" "WriteToCWLogs" {
  name = "WriteToCWLogsPolicy"
  policy = data.aws_iam_policy_document.WriteToCWLogs.json
}
# ---------------------------------------------------------------------------------------------------------------------
# Create LAMBDA DeleteAccessKeyPair function
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/lambda_function.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "DeleteAccessKeyPairRole" {
  name = "LambdaDeleteAccessKeyPairRole"
  assume_role_policy = local.TRUSTED_POLICY
}
resource "aws_iam_role_policy" "DeleteAccessKeyPairPolicy" {
  name = "DeleteIAMAccessKeyPairPolicy"
  role = aws_iam_role.DeleteAccessKeyPairRole.id
  policy = data.aws_iam_policy_document.DeleteIAMAccessKeyPair.json
}
resource "aws_iam_role_policy_attachment" "iam_inline_deleteaccess_attachment" {
  policy_arn = aws_iam_policy.WriteToCWLogs.arn
  role = aws_iam_role.DeleteAccessKeyPairRole.name
}
resource "aws_lambda_function" "DeleteAccessKeyPair" {
  function_name = "DeleteAccessKeyPair"
  handler = "delete_access_key_pair.lambda_handler"
  role = aws_iam_role.DeleteAccessKeyPairRole.arn
  runtime = "python3.6"
  filename = data.archive_file.DeleteAccessKeyPairZIP.output_path
  source_code_hash = data.archive_file.DeleteAccessKeyPairZIP.output_base64sha256
}

# ---------------------------------------------------------------------------------------------------------------------
# Create LAMBDA LookupCloudTrailEvents function
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/lambda_function.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "LookupCloudTrailEventsRole" {
  name = "LookupCloudTrailEventsRole"
  assume_role_policy = local.TRUSTED_POLICY
}
resource "aws_iam_role_policy" "LookupCloudTrailEventsPolicy" {
  name = "LookupCloudTrailEventsPolicy"
  role = aws_iam_role.LookupCloudTrailEventsRole.id
  policy = data.aws_iam_policy_document.LookupCloudTrailEvents.json
}
resource "aws_iam_role_policy_attachment" "iam_lookupcloud_inline_attachment" {
  policy_arn = aws_iam_policy.WriteToCWLogs.arn
  role = aws_iam_role.LookupCloudTrailEventsRole.name
}
resource "aws_lambda_function" "LookupCloudTrailEvents" {
  function_name = "LookupCloudTrailEvents"
  handler = "lookup_cloudtrail_events.lambda_handler"
  role = aws_iam_role.LookupCloudTrailEventsRole.arn
  runtime = "python3.6"
  filename = data.archive_file.LookupCloudTrailEventsZIP.output_path
  source_code_hash = data.archive_file.LookupCloudTrailEventsZIP.output_base64sha256
}

# ---------------------------------------------------------------------------------------------------------------------
# Create LAMBDA NotifySecurity function
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/lambda_function.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "SnsPublishRole" {
  name = "LambdaSnsPublishRole"
  assume_role_policy = local.TRUSTED_POLICY
}
resource "aws_iam_role_policy" "NotifySecurityPolicy" {
  name = "PublishToSNSTopic"
  role = aws_iam_role.SnsPublishRole.id
  policy = data.aws_iam_policy_document.PublishToSNSTopic.json
}
resource "aws_iam_role_policy_attachment" "iam_snspublish_inline_attachment" {
  policy_arn = aws_iam_policy.WriteToCWLogs.arn
  role = aws_iam_role.SnsPublishRole.name
}
resource "aws_lambda_function" "NotifySecurity" {
  function_name = "NotifySecurity"
  handler = "notify_security.lambda_handler"
  role = aws_iam_role.SnsPublishRole.arn
  runtime = "python3.6"
  filename = data.archive_file.NotifySecurityZIP.output_path
  source_code_hash = data.archive_file.NotifySecurityZIP.output_base64sha256
}