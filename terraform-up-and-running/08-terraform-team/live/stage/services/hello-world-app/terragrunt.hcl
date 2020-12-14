terraform {
  source = "../../../../modules//services/hello-world-app"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  environment = "stage"

  min_size = 2
  max_size = 2

  enable_autoscaling = false

  db_remote_state_bucket = "terraform-up-and-running-state-cusihuaman"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
}