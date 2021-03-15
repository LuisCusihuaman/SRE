# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH NOMAD SERVER NODE WHEN IT'S BOOTING
# This script will configure and start Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_server" {
  template = file("${path.module}/userdata-scripts/user-data-nomad-server.sh")

  vars = {
    num_servers = var.num_nomad_servers
    cluster_tag_key = var.cluster_tag_key
    cluster_tag_value = var.consul_cluster_name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CLIENT NODE WHEN IT'S BOOTING
# This script will configure and start Consul and Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_client" {
  template = file("${path.module}/userdata-scripts/user-data-nomad-client.sh")

  vars = {
    cluster_tag_key = var.cluster_tag_key
    cluster_tag_value = var.consul_cluster_name
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CONSUL SERVER EC2 INSTANCE WHEN IT'S BOOTING
# This script will configure and start Consul
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_consul_server" {
  template = file("${path.module}/userdata-scripts/user-data-consul-server.sh")

  vars = {
    cluster_tag_key = var.cluster_tag_key
    cluster_tag_value = var.consul_cluster_name
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CLUSTER IN THE DEFAULT VPC AND SUBNETS
# Using the default VPC and subnets makes this example easy to run and test, but it means Consul and Nomad are
# accessible from the public Internet. In a production deployment, we strongly recommend deploying into a custom VPC
# and private subnets.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_region" "current" {
}
