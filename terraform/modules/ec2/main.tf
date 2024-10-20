
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}


resource "aws_subnet" "private_ec2_subnets" {
  count                      = length(var.availability_zones)
  vpc_id                     = var.vpc_id
  cidr_block                 = cidrsubnet(var.vpc_subnet, 8, count.index + 1)
  assign_ipv6_address_on_creation = true       # Enable IPv6 on instance creation
  ipv6_cidr_block            = cidrsubnet(var.vpc_ipv6_cidr_block, 8, count.index)  # Assign IPv6 subnet
  availability_zone          = var.availability_zones[count.index]

  tags = merge(var.tags,
    {
      Name     = lower(format("net-%s-%03d", var.tags["project_name"], count.index + 1))
      Function = format("Private EC2 Host Subnets - %s", var.tags["project_name"])
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}


# Route Table for private subnets
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = lower(format("Private-RT-%s", var.tags["project_name"]))
  })
}

# Route for IPv4 (through Internet Gateway)
resource "aws_route" "ipv4_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}

# Route for IPv6 (through Egress-Only Internet Gateway)
resource "aws_route" "ipv6_route" {
  route_table_id                = aws_route_table.private.id
  destination_ipv6_cidr_block   = "::/0"
  egress_only_gateway_id = var.egress_only_internet_gateway_id
}

# Associate the route table with each private subnet
resource "aws_route_table_association" "private_subnet_assoc" {
  count          = length(aws_subnet.private_ec2_subnets)
  subnet_id      = aws_subnet.private_ec2_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}

# VPC Endpoint for SSM
resource "aws_vpc_endpoint" "ssm_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_ec2_subnets[*].id
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = merge(var.tags, {
    Name = format("SSM Endpoint - %s", var.tags["project_name"])
  })
}

resource "aws_security_group" "vpc_endpoint_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, {
    Name = "VPC Endpoint Security Group"
  })
}


# VPC Endpoint for SSM Messages
resource "aws_vpc_endpoint" "ssmmessages_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private_ec2_subnets[*].id
  security_group_ids = [aws_security_group.hosts_secgrp.id]

  tags = merge(var.tags, {
    Name = format("SSM Messages Endpoint - %s", var.tags["project_name"])
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  route_table_ids = [aws_route_table.private.id]
}


resource "aws_security_group" "hosts_secgrp" {
  vpc_id = var.vpc_id

  # Ingress for the load balancer (IPv4 and IPv6)
  ingress {
    from_port   = var.app_listening_port
    to_port     = var.app_listening_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Egress for all traffic (IPv4 and IPv6)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  # ingress {
  #   # Allow SSH
  #   from_port = 22
  #   to_port = 22
  #   protocol = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

#   ingress { #Allow Redis connections 
#     from_port   = var.redis_cluster.cluster_endpoint[0].port
#     to_port     = var.redis_cluster.cluster_endpoint[0].port
#     protocol    = "tcp"
#     cidr_blocks = var.redis_subnets.cidr_blocks
#   }

# ingress { #Allow Elastic connections 
#     from_port   = var.elastic_nodes.port[0]
#     to_port     = var.elastic_nodes.port[0]
#     protocol    = "tcp"
#     # cidr_blocks = var.elastic_subnets.cidr_blocks
#     cidr_blocks = [for subnet in var.elastic_subnets : subnet.cidr_block]

#   }

#   egress { #Allow Redis connections 
#     from_port   = var.redis_cluster.cluster_endpoint[0].port
#     to_port     = var.redis_cluster.cluster_endpoint[0].port
#     protocol    = "tcp"
#     cidr_blocks = var.redis_subnets.cidr_blocks
#   }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = format("EC2 Security Group - %s", var.tags["project_name"])
  })

}

resource "aws_autoscaling_group" "hosts_asg" {
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_capacity
  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  name_prefix         = lower(format("host-%s", var.tags["project_name"]))
  vpc_zone_identifier = aws_subnet.private_ec2_subnets[*].id
  # target_group_arns   = [var.load_balancer_target_group.arn]
  target_group_arns = [var.load_balancer_web_target_group_arn]


  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.host_launch_template.id
        version            = "$Latest"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.asg_desired_capacity
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "lowest-price"
      spot_instance_pools                      = 2
      # spot_max_price                          = "" # Optional: Set a max price for spot instances
    }
  }

  tag {
    key                 = "Name"
    value               = lower(format("asg-host-%s", var.tags["project_name"]))
    propagate_at_launch = true
  }

  tag {
    key                 = "PrivateCert"
    value               = "True"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_template" "host_launch_template" {
  name_prefix   = lower(format("asg-template-%s-", var.tags["project_name"]))
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.host_instance_type
  key_name      = var.key_name
  
  iam_instance_profile { 
      name = var.ec2_iam_profile_name
    }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.host_volume_size
      volume_type = "gp2"
    }
  }

  user_data = base64encode(
  templatefile("${path.root}/files/scripts/ec2_initial_script.sh.tftpl", {
    bucket_name = lower(format("s3-%s", var.tags["project_name"])),
    namespace = var.tags["app"],
    log_group_name = var.tags["project_name"],
    metrics_collection_interval = 1
  })
  )

  # depends_on = [var.cloudwatch_log]

  monitoring {
    enabled = true
  }

  instance_initiated_shutdown_behavior = "terminate"

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
    security_groups             = [aws_security_group.hosts_secgrp.id]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# resource "aws_cloudwatch_log_group" "ansible_logs" {
#   name              = var.tags["project_name"]  
#   retention_in_days = 14  
# }
