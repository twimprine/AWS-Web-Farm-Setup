output "external_alb_certificate_arn" {
  value = aws_acm_certificate.external_alb.arn
  description = "ARN of the ACM certificate for the external ALB"
}