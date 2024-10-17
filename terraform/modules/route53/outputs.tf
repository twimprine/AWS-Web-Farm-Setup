output "hosted_zone_id" {
  value = aws_route53_zone.hosted_zone.zone_id
  description = "ID Value of the created hosted zone"
}

output "hosted_zone_name" {
  value = aws_route53_zone.hosted_zone.name
  description = "Name of the created hosted zone"
}