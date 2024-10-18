resource "aws_vpc" "vpc" {
  cidr_block                           = var.vpc_subnet
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = true
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true

  tags = merge(var.tags, {
    Name = lower(format("VPC-%s", var.tags["project_name"]))
  })

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = lower(format("IGW-%s", var.tags["project_name"]))
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Egress-Only Internet Gateway for IPv6 traffic
resource "aws_egress_only_internet_gateway" "eogw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(var.tags, {
    Name = lower(format("EOIGW-%s", var.tags["project_name"]))
  })

  lifecycle {
    create_before_destroy = true
  }
}

