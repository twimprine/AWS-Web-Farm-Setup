
output "data_source_branch" {
  description = "Branch name from data source"
  value       = data.external.branch_name.result.branch_name
}
