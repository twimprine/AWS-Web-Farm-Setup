resource "aws_vpc" "vpc" {
  cidr_block                           = var.vpc_subnet
  enable_dns_hostnames                 = true
  enable_network_address_usage_metrics = true

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

