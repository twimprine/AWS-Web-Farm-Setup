########################
# Security Group
########################

resource "aws_security_group" "web_lb_secgrp" {
  name_prefix = "weblb-secgrp-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

########################
# Load Balancer
########################

resource "aws_lb" "web_lb" {
  name               = lower(format("web-lb-%s", var.tags["project_name"]))
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_lb_secgrp.id]
  subnets            = var.private_subnets[*].id
  idle_timeout       = var.alb_idle_timeout
  ip_address_type    = "dualstack"

  tags = var.tags
  
  lifecycle {
    create_before_destroy = true
  }
}

########################
# Target Group
########################

resource "aws_lb_target_group" "alb_target_group" {
  name_prefix = "albtg-"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
    protocol            = "HTTPS"
  }

  tags = merge(var.tags, {
    name = lower(format("tgtgrp-%s", var.tags["project_name"]))
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

########################
# Load Balancer Listeners
########################

# HTTPS Listener (port 443) with Forward to Target Group
resource "aws_lb_listener" "front_end_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.external_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP Listener (port 80) with Redirect to HTTPS (port 443)
resource "aws_alb_listener" "forward_80" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type  = "redirect"
    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
