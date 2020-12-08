provider "aws" {
  region = "us-east-1"
}
# REMOTE BACKEND -------------------------------------------------

terraform {
  backend "s3" {
    bucket = "terraform-up-and-running-state-cusihuaman"
    key = "stage/data-store/mysql/terraform.tfsate"
    region = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state-cusihuaman"
  # Prevent accidental deletion of this s3 bucket
  lifecycle {
    prevent_destroy = true
  }
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
# END REMOTE BACKEND -------------------------------------------------

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "mysql-master-password-stage-luis"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  name = "example_database"
  username = "admin"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}