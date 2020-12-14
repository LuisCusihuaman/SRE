terraform {
  source = "../../../../modules//data-stores/mysql"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  db_name = "example_stage"
  db_username = "admin"
}