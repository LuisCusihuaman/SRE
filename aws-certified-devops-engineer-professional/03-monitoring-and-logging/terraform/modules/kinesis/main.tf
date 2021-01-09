locals {
  KINESIS_ROLE_NAME = "FirehosetoS3Role"
  KINESIS_ASSUME_POLICY = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Action":"sts:AssumeRole",
      "Effect":"Allow",
      "Principal":{
        "Service":"firehose.amazonaws.com"
      }
    }
  ]
}
EOF
}

# Kinesis

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "firehose_s3_role" {
  name = local.KINESIS_ROLE_NAME
  assume_role_policy = local.KINESIS_ASSUME_POLICY
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "FirehosetoS3Policy"
  role = aws_iam_role.firehose_s3_role.name
  policy = templatefile("${path.module}/kinesis-to-s3-policy.json",
  {
    account_id = data.aws_caller_identity.current.account_id
    bucket_arn = var.bucket_kinesis_data_stream
  })
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "terraform-kinesis-firehose-extended-s3-test-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_s3_role.arn
    bucket_arn = var.bucket_kinesis_data_stream
  }
}
