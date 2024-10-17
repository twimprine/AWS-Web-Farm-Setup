#########################################
# VPC Outputs
#########################################
output "vpc_obj" {
  description = "Entire VPC Object"
  value       = aws_vpc.vpc
}

output "vpc_arn" {
  description = "The Amazon Resource Name (ARN) of the VPC"
  value       = aws_vpc.vpc.arn
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spun up within the VPC"
  value       = aws_vpc.vpc.instance_tenancy
}

output "vpc_enable_dns_support" {
  description = "Whether the VPC has DNS support enabled"
  value       = aws_vpc.vpc.enable_dns_support
}

output "vpc_enable_network_address_usage_metrics" {
  description = "Whether Network Address Usage metrics are enabled for the VPC"
  value       = aws_vpc.vpc.enable_network_address_usage_metrics
}

output "vpc_enable_dns_hostnames" {
  description = "Whether the VPC has DNS hostname support enabled"
  value       = aws_vpc.vpc.enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = aws_vpc.vpc.main_route_table_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the network ACL created by default on VPC creation"
  value       = aws_vpc.vpc.default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.vpc.default_security_group_id
}

output "vpc_default_route_table_id" {
  description = "The ID of the route table created by default on VPC creation"
  value       = aws_vpc.vpc.default_route_table_id
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = aws_vpc.vpc.ipv6_association_id
}

output "vpc_ipv6_cidr_block_network_border_group" {
  description = "The Network Border Group Zone name for the IPv6 CIDR block"
  value       = aws_vpc.vpc.ipv6_cidr_block_network_border_group
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = aws_vpc.vpc.owner_id
}

output "vpc_tags_all" {
  description = "A map of tags assigned to the VPC resource, including those inherited from the provider default_tags configuration block"
  value       = aws_vpc.vpc.tags_all
}

output "ipv6_cidr_block" {
  value = aws_vpc.vpc.ipv6_cidr_block
  description = "The IPv6 CIDR block of the VPC"
}
