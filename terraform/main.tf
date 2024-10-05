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


module "state" {
  source = "./modules/state"
  aws_region = var.aws_region
  project_name = local.project_name
  
  tags = merge(
    var.default_tags,
    {
      Name = lower(format("terraform-state-%s", var.project_name))
    }
  )
}