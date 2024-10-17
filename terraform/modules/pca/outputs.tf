output "private_ca_arn" {
  value       = aws_acmpca_certificate_authority.private_ca.arn
  description = "The ARN of the ACM Private Certificate Authority"
}
