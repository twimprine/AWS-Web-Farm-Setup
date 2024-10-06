
locals {

  availability_zones = slice(data.aws_availability_zones.available.names, 0,
  min(length(data.aws_availability_zones.available.names), 3))

  branch = data.external.branch_name.result.branch_name

  combined_tags = merge(var.tags, {
    branch = local.branch
  })

  project_name = local.branch == "main" ? lower(format("%s", var.project_name)) : lower(format("%s-%s", var.project_name, local.branch))


}
