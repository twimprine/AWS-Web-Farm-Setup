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

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for record in aws_acm_certificate.external_alb.domain_validation_options : record.domain_name => {
      name    = record.resource_record_name
      type    = record.resource_record_type
      value   = record.resource_record_value
    }
  }

  zone_id         = var.dns_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.value]
  ttl             = 60
}