# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket used for the database's remote state storage"
  type = string
}

variable "db_remote_state_key" {
  description = "The name of the key in the S3 bucket used for the database's remote state storage"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances in the ASG"
  type = number
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

variable "alb_name" {
  description = "The name of the ALB"
  type = string
  default = "terraform-asg-example"
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  type = string
  default = "terraform-example-instance"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type = string
  default = "terraform-example-alb"
}


