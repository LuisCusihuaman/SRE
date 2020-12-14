remote_state {
  backend = "s3"
  config = {
    bucket = "terraform-up-and-running-state-cusihuaman"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-up-and-running-locks"
  }
}