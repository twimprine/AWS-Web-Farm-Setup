####################
# Deployment variables
####################

variable "application_settings" {
  description = "Application settings"
  type = object({
    app_listening_port  = number
    app_name            = string
    high_availability   = bool
    region              = string
  })
}

variable "autoscaling" {
  description = "Autoscaling attributes"
  type = object({
    desired_capacity = number
    max_size         = number
    min_size         = number
  })
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "deployment_options" {
  description = "Deployment options"
  type = object({
    enable_blue_green_deploy   = bool
    enable_canary_deploy       = bool
    enable_deployment_approval = bool
    enable_inplace_deploy      = bool
    github_deploy              = bool
    remote_state               = bool
  })
}

variable "ec2" {
  description = "EC2 Instance Attributes"
  type = object({
    instance_type = string
    key_name      = string
    volume_size   = number
  })
}

variable "project_name" {
  description = "Project Name (e.g., webapp). This will be the prefix for the domain and resources."
  type        = string
}

variable "redis" {
  description = "Redis attributes"
  type = object({
    cluster_enabled = bool
    enabled         = bool
    instance_type   = string
    multi_az        = bool
  })
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

variable "vpc_subnet_cidr" {
  description = "CIDR block for the VPC subnet"
  type        = string
}

variable "route_53" {
  description = "Route 53 attributes"
  type = object({
    root_domain_name = string
    root_zone_id     = string
    app_subdomain    = string
  })
}