########################
# Provider Configuration
########################

# AWS provider with default tags
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(local.combined_tags, {
      project_name = format(lower(local.project_name))
    })
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

# Application Load Balancer Module - Creates an Application Load Balancer
module "alb" {
  source = "./modules/alb"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  aws_region = var.aws_region
  external_certificate_arn = module.acm.external_alb_certificate_arn
  hosts_app_listening_port = var.application_settings.app_listening_port
  private_subnets = module.ec2.ec2_host_subnets
  vpc_id = module.vpc.vpc_id
}

# Cloudwatch Module - Application Logging settings and configs
module "cloudwatch" {
  source = "./modules/cloudwatch"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  log_retention_days = var.cloudwatch.log_retention_days
}

# EC2 Module - Creates EC2 instances, security groups, and autoscaling groups
module "ec2" {
  source = "./modules/ec2"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )
  # General settings
  availability_zones = local.availability_zones
  region = var.aws_region

  # VPC and network settings
  egress_only_internet_gateway_id = module.vpc.egress_only_internet_gateway_id
  internet_gateway_arn = module.vpc.internet_gateway_arn
  internet_gateway_id = module.vpc.internet_gateway_id
  vpc_id = module.vpc.vpc_id
  vpc_ipv6_cidr_block = module.vpc.ipv6_cidr_block
  vpc_subnet = var.vpc_subnet_cidr

  # EC2 settings
  associate_public_ip_address = var.ec2.associate_public_ip_address
  ec2_iam_profile_name = module.iam.ec2_iam_profile_name
  host_instance_type = var.ec2.instance_type
  host_volume_size = var.ec2.volume_size
  key_name = var.ec2.key_name

  # Application settings
  app_listening_port = var.application_settings.app_listening_port

  # Autoscaling settings
  asg_desired_capacity = var.autoscaling.desired_capacity
  asg_max_size = var.autoscaling.max_size
  asg_min_size = var.autoscaling.min_size

  # Load balancer settings
  load_balancer_web_target_group_arn = module.alb.web_target_group_arn
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
  private_ca_arn = module.pca.private_ca_arn
}

# Private Certificate Authority Module - Creates a private certificate authority - pca
module "pca" {
  source = "./modules/pca"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  aws_region = var.aws_region

  key_algorithm = var.pca.key_algorithm
  signing_algorithm = var.pca.signing_algorithm

  certificate_validity_length = var.pca.certificate_validity_length
  certificate_validity_timeperiod = var.pca.certificate_validity_timeperiod

  common_name = var.pca.subject.common_name
  country = var.pca.subject.country
  locality = var.pca.subject.locality
  organization = var.pca.subject.organization
  organizational_unit = var.pca.subject.organizational_unit
  state = var.pca.subject.state
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

  pca_arn = module.pca.private_ca_arn
  pca = var.pca
  region = var.aws_region


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
