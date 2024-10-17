provider "aws" {
  region = var.region
}

# Hosted Zone for the subdomain 
resource "aws_route53_zone" "hosted_zone" {
  name = lower(format("%s.%s", var.tags["project_name"], var.root_domain))

  tags = var.tags
}

# NS record in the root domain for the subdomain delegation
resource "aws_route53_record" "nameserver" {
  zone_id = var.root_zone_id
  name    = lower(format("%s", var.tags["project_name"]))
  type    = "NS"
  ttl     = "300"
  records = aws_route53_zone.hosted_zone.name_servers
}


# resource "aws_route53_record" "demo_example" {
#   zone_id = aws_route53_zone.demo.zone_id
#   name    = "www"
#   type    = "A"
#   ttl     = "300"
#   records = ["YOUR_IP_ADDRESS"]
# }
