# output "alb_dns_name" {
#   value = aws_lb.alb.dns_name
# }

# output "alb_object" {
#   value = aws_lb.alb
# }

# output "alb_target_group" {
#   value = aws_lb_target_group.alb_target_group
# }

output "web_target_group_arn" {
  value       = aws_lb_target_group.alb_target_group.arn
  description = "The ARN of the web server target group for the ALB"
}