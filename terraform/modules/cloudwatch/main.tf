
resource "aws_cloudwatch_log_group" "project_logs" {
  name              = var.tags["project_name"]  
  retention_in_days = 14  
}