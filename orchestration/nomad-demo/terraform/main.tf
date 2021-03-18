provider "aws" {
  region = "us-east-1"
}
locals {
  MY_PUBLIC_IP = "${chomp(data.http.my_ip.body)}/32"
}

//module "vpc" {
//  source = "terraform-aws-modules/vpc/aws"
//  name = "HashiCorp-Nomad-VPC"
//  cidr = "10.0.0.0/16"
//  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]
//  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
//  public_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
//
//  enable_nat_gateway = true
//  single_nat_gateway = false
//  one_nat_gateway_per_az = false
//}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A NOMAD CLUSTER AND A SEPARATE CONSUL CLUSTER IN AWS
# These templates show an example of how to use the nomad-cluster module to deploy a Nomad cluster in AWS. This cluster
# connects to Consul running in a separate cluster.
#
# We deploy two Auto Scaling Groups (ASGs) for Nomad: one with a small number of Nomad server nodes and one with a
# larger number of Nomad client nodes. Note that these templates assume that the AMI you provide via the
# nomad_ami_id input variable is built from the examples/nomad-consul-ami/nomad-consul.json Packer template.
#
# We also deploy one ASG for Consul which has a small number of Consul server nodes. Note that these templates assume
# that the AMI you provide via the consul_ami_id input variable is built from the examples/consul-ami/consul.json
# Packer template in the Consul AWS Module.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------

module "nomad_servers" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=v0.7.2"

  cluster_name  = "${var.nomad_cluster_name}-server"
  instance_type = "t2.micro"

  # You should typically use a fixed size of 3 or 5 for your Nomad server cluster
  min_size         = var.num_nomad_servers
  max_size         = var.num_nomad_servers
  desired_capacity = var.num_nomad_servers

  ami_id       = var.ami_id
  user_data    = data.template_file.user_data_nomad_server.rendered
  ssh_key_name = var.ssh_key_name

  vpc_id                      = data.aws_vpc.default.id
  subnet_ids                  = data.aws_subnet_ids.default.ids
  allowed_ssh_cidr_blocks     = [local.MY_PUBLIC_IP]
  allowed_inbound_cidr_blocks = [local.MY_PUBLIC_IP]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our server Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.8.0"

  iam_role_id = module.nomad_servers.iam_role_id
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# ---------------------------------------------------------------------------------------------------------------------

module "nomad_clients" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=v0.0.1"
  source = "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=v0.7.2"

  cluster_name  = "${var.nomad_cluster_name}-client"
  instance_type = "t2.micro"

  # Give the clients a different tag so they don't try to join the server cluster
  cluster_tag_key   = "nomad-clients"
  cluster_tag_value = var.nomad_cluster_name

  # To keep the example simple, we are using a fixed-size cluster. In real-world usage, you could use auto scaling
  # policies to dynamically resize the cluster in response to load.

  min_size         = var.num_nomad_clients
  max_size         = var.num_nomad_clients
  desired_capacity = var.num_nomad_clients
  ami_id           = var.ami_id
  user_data        = data.template_file.user_data_nomad_client.rendered
  ssh_key_name     = var.ssh_key_name

  vpc_id                      = data.aws_vpc.default.id
  subnet_ids                  = data.aws_subnet_ids.default.ids
  allowed_ssh_cidr_blocks     = [local.MY_PUBLIC_IP]
  allowed_inbound_cidr_blocks = [local.MY_PUBLIC_IP]

  ebs_block_devices = [
    {
      device_name = "/dev/xvde"
      volume_size = "10"
    },
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_clients" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.8.0"

  iam_role_id = module.nomad_clients.iam_role_id
}
# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE CONSUL SERVER NODES
# ---------------------------------------------------------------------------------------------------------------------

module "consul_servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.8.0"

  cluster_name  = "${var.consul_cluster_name}-server"
  cluster_size  = var.num_consul_servers
  instance_type = "t2.micro"

  # The EC2 Instances will use these tags to automatically discover each other and form a cluster
  cluster_tag_key   = var.cluster_tag_key
  cluster_tag_value = var.consul_cluster_name

  ami_id       = var.ami_id
  user_data    = data.template_file.user_data_consul_server.rendered
  ssh_key_name = var.ssh_key_name

  vpc_id                      = data.aws_vpc.default.id
  subnet_ids                  = data.aws_subnet_ids.default.ids
  allowed_ssh_cidr_blocks     = []
  allowed_inbound_cidr_blocks = [local.MY_PUBLIC_IP]

}
