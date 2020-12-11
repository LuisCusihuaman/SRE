provider "aws" {
  region = "us-east-1"
}
module "webserver_cluster" {
  source = "../../../../modules/services/webserver-cluster"
  cluster_name = "webservers-prod"
  db_remote_state_bucket = "terraform-up-and-running-state-cusihuaman"
  db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "m4.large"
  max_size = 2
  min_size = 10
  custom_tags = {
    Owner = "team-foo"
    DeployedBy = "terraform"
  }
  enable_autoscaling = true
}