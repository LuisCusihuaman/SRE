terraform {
  backend "s3" {
    bucket         = "terraform-up-and-running-state-cusihuaman"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-04d29b6f966df1537"
  instance_type = terraform.workspace == "default" ? "t2.medium": "t2.micro"
}
