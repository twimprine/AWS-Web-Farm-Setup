provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}


resource "aws_alb" "alb" {
  name               = lower(format("alb-%s-%s-%s", var.tags["Customer"], var.tags["Project"], var.tags["Environment"]))
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_secgrp.id]
  subnets            = var.private_subnets[*].id
  idle_timeout       = var.alb_idle_timeout


  tags = merge(var.tags,
    {
      name = lower(format("ALB-%s-%s-%s", var.tags["Customer"], var.tags["Project"], var.tags["Environment"]))
    }
  )

  /* lifecycle {
    create_before_destroy = true
  } */

}



# resource "aws_lb_listener" "front_end_listener" {
#   load_balancer_arn = aws_alb.alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn
#   # certificate_arn = data.aws_acm_certificate.alb_certificate.arn


#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.alb_target_group.arn
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

resource "aws_alb_listener" "forward_80" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  # default_action {
  #   #### Change to forward port 80 remove certificate
  #   order = 1
  #   type  = "redirect"
  #   redirect {
  #     host        = "#{host}"
  #     path        = "/#{path}"
  #     port        = "443"
  #     protocol    = "HTTPS"
  #     query       = "#{query}"
  #     status_code = "HTTP_301"
  #   }
  # }
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    order            = 1
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name_prefix = "albtg-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(var.tags,
    {
      name = lower(format("tgtgrp-%s-%s-%s", var.tags["Customer"], var.tags["Project"], var.tags["Environment"]))
    }
  )
}

resource "aws_security_group" "alb_secgrp" {
  name_prefix = "albsrc-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
