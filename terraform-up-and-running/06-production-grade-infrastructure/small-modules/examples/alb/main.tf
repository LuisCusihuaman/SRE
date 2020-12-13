provider "aws" {
  region = "us-east-1"
}
module "alb" {
  source = "../../modules/networking/alb"
  alb_name = var.alb_name
  subnets_ids = data.aws_subnet-ids.default.ids
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}