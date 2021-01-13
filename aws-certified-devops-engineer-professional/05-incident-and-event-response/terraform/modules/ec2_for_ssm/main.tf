provider "aws" {
  region = "us-east-2"
}

locals {
  AMI_AM2 = "ami-0a0ad6b70e61be944"
  SSM_POLICY_NAME = "AmazonSSMRoleForInstancesQuickSetup"
  envs = toset(["Development", "Production"])
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_ssm"
  role = local.SSM_POLICY_NAME
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
  for_each = local.envs
  tags = {
    Name = "SSM"
    Environment = each.value
  }
}
