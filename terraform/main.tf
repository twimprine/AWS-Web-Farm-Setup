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