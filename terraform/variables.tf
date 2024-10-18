########################
# Deployment Variables
########################

# General Project and AWS Settings
variable "project_name" {
  description = "Project Name (e.g., webapp). This will be the prefix for the domain and resources."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

########################
# Application Configuration
########################

variable "application_settings" {
  description = "Application settings"
  type = object({
    app_listening_port  = number
    app_name            = string
    high_availability   = bool
  })
}


########################
# Cloudwatch Configuration
########################

variable "cloudwatch" {
  description = "Cloudwatch attributes"
  type = object({
    log_retention_days = number
  })
}

########################
# EC2 Configuration
########################

variable "ec2" {
  description = "EC2 Instance Attributes"
  type = object({
    instance_type = string
    key_name      = string
    volume_size   = number
  })
}

########################
# Redis Configuration
########################

variable "redis" {
  description = "Redis attributes"
  type = object({
    cluster_enabled = bool
    enabled         = bool
    instance_type   = string
    multi_az        = bool
  })
}

########################
# Autoscaling Configuration
########################

variable "autoscaling" {
  description = "Autoscaling attributes"
  type = object({
    desired_capacity = number
    max_size         = number
    min_size         = number
  })
}

########################
# VPC and Network Configuration
########################

variable "vpc_subnet_cidr" {
  description = "CIDR block for the VPC subnet"
  type        = string
}

########################
# Deployment Options
########################

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

########################
# Route 53 Configuration
########################

variable "route_53" {
  description = "Route 53 attributes"
  type = object({
    root_domain_name = string
    root_zone_id     = string
    app_subdomain    = string
  })
}

########################
# Private Certificate Authority Configuration
########################
variable "pca" {
  description = "Private Certificate Authority attributes"
  type = object({
    key_algorithm    = string
    signing_algorithm = string
    certificate_validity_length = number
    certificate_validity_timeperiod = string
    subject = object({
      common_name        = string
      country            = string
      locality           = string
      organization       = string
      organizational_unit = string
      state              = string
    })
  })
}