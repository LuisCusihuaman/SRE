terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
  # Remote State Storage
  backend "s3" {
    bucket = "cusihuaman-on-aws-eks" # CHANGE THIS
    key    = "dev/eks-irsa-demo/terraform.tfstate"
    region = "us-east-1"

    # For State Locking
    dynamodb_table = "dev-eks-irsa-demo"
  }
}