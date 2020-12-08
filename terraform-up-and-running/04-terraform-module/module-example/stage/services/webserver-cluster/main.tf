provider "aws" {
  region = "us-east-1"
}
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-stage"
  db_remote_state_bucket = "terraform-up-and-running-state-cusihuaman"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  max_size = 2
  min_size = 2
}
