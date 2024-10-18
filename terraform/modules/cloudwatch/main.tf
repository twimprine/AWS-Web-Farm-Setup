
resource "aws_cloudwatch_log_group" "project_logs" {
    name              = var.tags["project_name"]  
    retention_in_days = var.log_retention_days


    lifecycle {
        create_before_destroy = true
    }
}