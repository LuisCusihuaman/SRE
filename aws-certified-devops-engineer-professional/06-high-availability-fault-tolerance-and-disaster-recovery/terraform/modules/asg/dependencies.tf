data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}