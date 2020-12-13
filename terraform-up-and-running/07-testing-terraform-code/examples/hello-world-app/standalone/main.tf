provider "aws" {
  region = "us-east-1"
}

module "hello_world_app" {
  source = "../../../modules/services/hello-world-app"

  server_text = "Hello, World"
  environment = "example"

  db_remote_state_bucket = "terraform-up-and-running-state-cusihuaman"
  db_remote_state_key = "example/terraform.tfstate"

  mysql_config = var.mysql_config

  instance_type = "t2.micro"
  max_size = 2
  min_size = 2
  enable_autoscaling = false
}
