terraform {
  source = "github.com/LuisCusihuaman/SRE/tree/master/terraform-up-and-running/08-terraform-team/modules/data-stores//mysql?ref=v0.0.2"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  db_name = "example_stage"
  db_username = "admin"
}