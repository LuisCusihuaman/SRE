provider "aws" {
  region = "us-east-2"
}

locals {
  AMI_UBUNTU = "ami-0a91cd140a1fc148a"
}
variable "key_name" {
  type = string
  default = "ansible"
}
variable "key_path" {
  type = string
  description = "public key path"
}

resource "aws_key_pair" "generated_key" {
  key_name = var.key_name
  public_key = file(var.key_path)
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
  count = 2
  ami = local.AMI_UBUNTU
  instance_type = "t2.micro"
  key_name = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Name = "ansible-target"
  }
}

resource "local_file" "hosts" {
  filename = "../hosts"
  content = <<EOF
[frontends]
${aws_instance.ec2_instance[0].public_dns}
${aws_instance.ec2_instance[1].public_dns}
EOF
}