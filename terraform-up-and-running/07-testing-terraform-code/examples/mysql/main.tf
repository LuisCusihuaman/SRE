provider "aws" {
  region = "us-east-1"
  version = "~> 2.0"
}

module "mysql" {
  source = "../../modules/data-stores/mysql"
  db_name = var.db_name
  db_password = var.db_password
  db_username = var.db_username
}