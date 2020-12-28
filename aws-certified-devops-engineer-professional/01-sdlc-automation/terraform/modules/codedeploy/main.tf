# ---------------------------------------------------------------------------------------------------------------------
# Create IAM Role for CodeDeploy group by assuming role and service-role
# Provider Docs: https://www.terraform.io/docs/providers/aws/r/iam_role.html
# Data Docs: https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "codedeploy" {
  statement {
    principals {
      type = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_policy" "policy" {
  name = "s3-artifacts-access"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.bucket_deploy_revisions.arn}",
        "${aws_s3_bucket.bucket_deploy_revisions.arn}/*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role" "this" {
  name = "CodeDeployRole"
  assume_role_policy = data.aws_iam_policy_document.codedeploy.json
}
resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role = aws_iam_role.this.name
}

# ---------------------------------------------------------------------------------------------------------------------
# Create CodeDeploy Application
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_app
# Data Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codedeploy-application.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_codedeploy_app" "git_deploy_app" {
  name = "CodeDeployDemo"
  compute_platform = "Server"
}
# ---------------------------------------------------------------------------------------------------------------------
# Create an Deployment Group for CD App
# Provider Docs:https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group
# Data Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codedeploy-deploymentgroup.html
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_codedeploy_deployment_group" "git_deploy_group" {
  app_name = aws_codedeploy_app.git_deploy_app.name
  deployment_group_name = var.tier == "dev" ? "MyDevelopmentInstances": "MyProdInstnaces"
  service_role_arn = aws_iam_role.this.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_style {
    deployment_type = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key = "Environment"
      value = var.tier == "dev"? "Development": "Production"
      type = "KEY_AND_VALUE"
    }
  }
}
# SG
resource "aws_security_group" "instance" {
  name = "webserver_sg"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "webserver_sg"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Create EC2 Instances
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# Data Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-instance.html
# ---------------------------------------------------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2" {
  statement {
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "ec2_role" {
  name = "EC2RoleCodeDeploy"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}
resource "aws_iam_role_policy_attachment" "AWSCodeDeployS3Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
  role = aws_iam_role.ec2_role.name
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_codedeploy_profile"
  role = aws_iam_role.ec2_role.name
}
resource "aws_instance" "web_server" {
  count = var.tier == "dev" ? 1:3
  ami = "ami-04d29b6f966df1537" // amazon linux 1  | us-east-1
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  tags = {
    Name = "web_server"
    Environment = var.tier == "dev" ? "Development": "Production"
  }
  user_data = file("${path.module}/user-data.sh")
}
# ---------------------------------------------------------------------------------------------------------------------
# Create an S3 Bucket with versioning and encryption
# Provider Docs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# Data Docs: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-instance.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "bucket_deploy_revisions" {
  bucket = "aws-devops-course-cusihuaman"
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
# ---------------------------------------------------------------------------------------------------------------------
# Deploy the deployment scripts into S3
# ---------------------------------------------------------------------------------------------------------------------
resource "null_resource" "deploy_revision_app" {
  provisioner "local-exec" {
    command = "aws deploy push --application-name ${aws_codedeploy_app.git_deploy_app.name} --source ${path.module}/../codecommit/cicd-demo-repo --s3-location s3://${aws_s3_bucket.bucket_deploy_revisions.id}/codedeploy-demo/app.zip --ignore-hidden-files --region us-east-1"
  }
  depends_on = [aws_instance.web_server, aws_s3_bucket.bucket_deploy_revisions]
}
