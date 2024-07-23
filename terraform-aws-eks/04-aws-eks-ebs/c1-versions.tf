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
  }
  # Remote State Storage
  backend "s3" {
    bucket = "cusihuaman-on-aws-eks" # CHANGE THIS
    key    = "dev/ebs-storage/terraform.tfstate"
    region = "us-east-1"

    # For State Locking
    dynamodb_table = "dev-ebs-storage"
  }
}
