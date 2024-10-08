output "alb_dns_name" {
  value = aws_alb.alb.dns_name
}

output "alb_object" {
  value = aws_alb.alb
}

output "alb_target_group" {
  value = aws_lb_target_group.alb_target_group
}