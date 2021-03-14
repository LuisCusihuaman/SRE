provider "aws" {
  region = "us-east-1"
}

module "vpc"{
  source = "terraform-aws-modules/vpc/aws"
  name = "HashiCorp-Nomad-VPC"
  cidr = "10.0.0.0/16"
  azs = ["us-east-1a","us-east-1b","us-east-1c"]
  private_subnets = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19"]
  public_subnets = ["10.0.128.0/20","10.0.144.0/20","10.0.160.0/20"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = false
}