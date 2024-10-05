# provider configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_tags
  }
}

data "external" "branch_name" {
  program = ["bash", "${path.module}/get_branch_name.sh"]
}

module "vpc" {
  source = "./modules/vpc"

  tags = merge(var.default_tags, {
    branch = data.external.branch_name.result
  })
  vpc_subnet = var.vpc_subnet_cidr
  availability_zones = local.availability_zones
}