terraform {
  source = "github.com/luiscusihuaman/SRE.git//terraform-up-and-running/08-terraform-team/modules/data-stores/mysql?ref=v0.0.3"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  db_name = "example_stage"
  db_username = "admin"
}