# provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.combined_tags
  }
}



data "aws_default_tags" "default_tags" {}

data "external" "branch_name" {
  program = ["bash", "${path.module}/get_branch_name.sh"]
}

data "aws_availability_zones" "available" {}


# Create the VPC to house our resources and internet gateway
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


# Create the EC2 instances, security groups and autoscaling group(s)
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
  # project_name = local.project_name
  vpc_subnet = var.vpc_subnet_cidr
  host_volume_size = var.ec2.volume_size
  asg_desired_capacity = var.autoscaling.desired_capacity
  asg_max_size = var.autoscaling.max_size
  asg_min_size = var.autoscaling.min_size
  vpc_id = module.vpc.vpc_id
}

# Create s3 bucket for Ansible and other config files
module "s3" {
  source = "./modules/s3"

  tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )
 
}

module "iam" {
  source = "./modules/iam"
   tags = merge(
    data.aws_default_tags.default_tags.tags, {
      project_name = format(lower(local.project_name))
    }
  )

  config_bucket_name = module.s3.config_bucket_name
}

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