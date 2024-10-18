output "cloudwatch_log" {
    description = "CloudWatch Log Group ARN"
    value = aws_cloudwatch_log_group.project_logs
}