# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
  type = string
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
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

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
  type = bool
}

variable "custom_tags" {
  description = "Custom tags to set on the Instances in the ASG"
  type = map(string)
  default = {}
}

variable "ami" {
  description = "The AMI to run in the cluster"
  default = "ami-0885b1f6bd170450c"
  type = string
}
variable "server_text" {
  description = "The text the webserver should return"
  default = "Hello, world"
  type = string
}