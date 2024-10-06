####################
# Deployment variables
####################

# variable "availability_zones" {
#   description = "AWS Availability Zones"
#   type        = list(string)
# }

variable "autoscaling"{
  description = "Autoscaling attributes"
  type        = map(string)
}

variable "github_deploy"{
  description = "Deploy from GitHub or from local system"
  type        = bool
}

variable "remote_state" {
  description = "Enable remote state storage"
  type        = bool
}

variable "configure_ha" {
  description = "Configure HA for the cluster"
  type        = bool
}

variable "project_name" {
  description = "Project Name (e.g. webapp) this will be the prefix for the domain and resources"
  type        = string
}

variable "root_domain" {
  description = "Root domain name for the project (e.g. example.com)"
  type        = string
}

# variable "combined_tags" {
#   description = "Tags to apply to all resources"
#   type        = map(string)
# }

# variable "default_tags" {
#   description = "Tags to apply to all resources"
#   type        = map(string)
# }

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
variable "aws_region" {
  description = "AWS region to deploy resources"
}

variable "vpc_subnet_cidr" {
  description = "CIDR block for the VPC subnet"
}

variable "host_instance_type" {
  description = "How big are your workers"
  type        = string
}

# variable "branch" {
#   description = "Current Git branch name"
#   type        = string
# }
