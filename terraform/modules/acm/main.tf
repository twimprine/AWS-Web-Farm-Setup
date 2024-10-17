resource "aws_acm_certificate" "external_alb" {

  domain_name = var.dns_zone
  validation_method = "DNS"
  
  tags = {
    Name = lower(format("external-alb.%s", var.tags["project_name"]))
  }

  lifecycle {
    create_before_destroy = true
  }
  
}