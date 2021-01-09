locals {
  LOGS_ROLE_NAME = "CWLtoKinesisFirehoseRole"
  LOGS_ASSUME_POLICY = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Action":"sts:AssumeRole",
      "Effect":"Allow",
      "Principal":{
        "Service":"logs.us-east-2.amazonaws.com"
      }
    }
  ]
}
EOF
}

# METRICS AND ALARMS
resource "aws_cloudwatch_log_metric_filter" "ec2_access_log_metric_filter" {
  log_group_name = "access_log"
  name = "statuscode-404"
  pattern = "[host, logName, user, timestamp, request, statusCode=404, size]"
  metric_transformation {
    name = "404NotFound"
    namespace = "LogMetrics"
    value = "1"
  }
}
resource "aws_cloudwatch_metric_alarm" "ec2_access_log_metric_alarm" {
  alarm_name = "TooMany404"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold = "5"
  evaluation_periods = "1"
  metric_name = "404NotFound"
  namespace = "LogMetrics"
  period = "300"
  statistic = "Sum"
  alarm_description = "This metric monitors ec2 httpd 404 errors"
  insufficient_data_actions = []
}

# LOG SUBSCRIPTION
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "kinesis_log_role" {
  name = local.LOGS_ROLE_NAME
  assume_role_policy = local.LOGS_ASSUME_POLICY
}

resource "aws_iam_role_policy" "cwl_policy" {
  name = "InlineCWLToFirehosePolicy"
  role = aws_iam_role.kinesis_log_role.name
  policy = templatefile("${path.module}/cwl-filter-policy.json",
  {
    logs_role_name = local.LOGS_ROLE_NAME
    account_id = data.aws_caller_identity.current.account_id
    kinesis_stream_arn = var.kinesis_stream_arn
  })
}

resource "aws_cloudwatch_log_subscription_filter" "kinesis_subscription" {
  name = "Destination_to_kinesis"
  role_arn = aws_iam_role.kinesis_log_role.arn
  destination_arn = var.kinesis_stream_arn
  log_group_name = "access_log"
  filter_pattern = ""
}