########################
# Provider Configuration
########################

# AWS provider with default tags
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.combined_tags
  }
}

########################
# Data Sources
########################

# Default tags
data "aws_default_tags" "default_tags" {}

# Branch name (external)
data "external" "branch_name" {
  program = ["bash", "${path.module}/get_branch_name.sh"]
}

# Availability zones
data "aws_availability_zones" "available" {}

########################
# Modules
########################

# ACM Module - Manages SSL certificates
module "acm" {
  source = "./modules/acm"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  dns_zone = module.route53.hosted_zone_name
  dns_zone_id = module.route53.hosted_zone_id
  aws_region = var.aws_region
}

# EC2 Module - Creates EC2 instances, security groups, and autoscaling groups
module "ec2" {
  source = "./modules/ec2"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  app_listening_port = var.application_settings.app_listening_port
  availability_zones = local.availability_zones
  host_instance_type = var.ec2.instance_type
  vpc_subnet = var.vpc_subnet_cidr
  host_volume_size = var.ec2.volume_size
  asg_desired_capacity = var.autoscaling.desired_capacity
  asg_max_size = var.autoscaling.max_size
  asg_min_size = var.autoscaling.min_size
  vpc_id = module.vpc.vpc_id
}

# IAM Module - Configures IAM policies and roles
module "iam" {
  source = "./modules/iam"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  config_bucket_name = module.s3.config_bucket_name
}

# Route 53 Module - Manages DNS records
module "route53" {
  source = "./modules/route53"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  region = var.aws_region
  root_domain = var.route_53.root_domain_name
  root_zone_id = var.route_53.root_zone_id
}

# S3 Module - Creates an S3 bucket for Ansible and config files
module "s3" {
  source = "./modules/s3"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )
}

# VPC Module - Creates VPC and Internet Gateway
module "vpc" {
  source = "./modules/vpc"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  vpc_subnet = var.vpc_subnet_cidr
  availability_zones = local.availability_zones
}
