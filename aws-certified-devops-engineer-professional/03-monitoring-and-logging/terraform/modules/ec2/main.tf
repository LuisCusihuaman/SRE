locals {
  AMI_AM2 = "ami-0a0ad6b70e61be944"
  CW_AGENT_ARN = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
  EC2_ASSUME_POLICY = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ec2_role" {
  name = "AWSCloudWatchRoleForEC2"
  assume_role_policy = local.EC2_ASSUME_POLICY
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attachment" {
  role = aws_iam_role.ec2_role.name
  policy_arn = local.CW_AGENT_ARN
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_logging_profile"
  role = aws_iam_role.ec2_role.name
}

# SG
resource "aws_security_group" "ec2_sg" {
  name = "webserver_sg"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
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

resource "aws_instance" "ec2_instance" {
  ami = local.AMI_AM2
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = file("${path.module}/user-data.sh")
  depends_on = [aws_ssm_parameter.ec2_log_agent_config]
  tags = {
    Name = "LoggingInstance"
  }
}

resource "aws_ssm_parameter" "ec2_log_agent_config" {
  name = "AmazonCloudWatch-linux"
  type = "String"
  value = file("${path.module}/aws-cw-agent-config.json")
}