
locals {
  branch = data.external.branch_name.result.branch_name
  
  project_name = var.branch == "main" ? lower(format("%s", var.project_name)) : lower(format("%s-%s", var.project_name, var.branch))

    availability_zones = slice(data.aws_availability_zones.available.names, 0,
  min(length(data.aws_availability_zones.available.names), 3))

}
