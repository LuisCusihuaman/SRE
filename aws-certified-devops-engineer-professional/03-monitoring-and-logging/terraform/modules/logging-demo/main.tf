provider "aws" {
  region = "us-east-2"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create an S3 Bucket with versioning and encryption
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# Data Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-instance.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "bucket_kinesis_data_stream" {
  bucket = var.bucket_name_cwl_to_kinesis
  force_destroy = true
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "ec2" {
  source = "../ec2"
}

module "kinesis_firehose" {
  source = "../kinesis"
  bucket_kinesis_data_stream = aws_s3_bucket.bucket_kinesis_data_stream.arn
}

module "cloudwatch" {
  source = "../cloudwatch"
  kinesis_stream_arn = module.kinesis_firehose.kinesis_firehose_delivery_stream_arn
}