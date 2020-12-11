provider "aws" {
  region = "us-east-1"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
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