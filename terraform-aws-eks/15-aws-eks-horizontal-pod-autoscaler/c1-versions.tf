terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.0"
    }
  }
  # Remote State Storage
  backend "s3" {
    bucket = "cusihuaman-on-aws-eks" # CHANGE THIS
    key    = "dev/aws-eks-metrics-server/terraform.tfstate"
    region = "us-east-1"

    # For State Locking
    dynamodb_table = "aws-eks-metrics-server"
  }
}

# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
}
