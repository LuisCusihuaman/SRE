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
    http = {
      source  = "hashicorp/http"
      version = "3.4.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
  # Remote State Storage
  backend "s3" {
    bucket = "cusihuaman-on-aws-eks" # CHANGE THIS
    key    = "dev/aws-efs-csi/terraform.tfstate"
    region = "us-east-1"

    # For State Locking
    dynamodb_table = "dev-aws-efs-csi"
  }
}

# Terraform AWS Provider Block
provider "aws" {
  region = var.aws_region
}

# Terraform HTTP Provider Block
provider "http" {
  # Configuration options
}