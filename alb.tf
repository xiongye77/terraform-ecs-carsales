resource "aws_security_group" "carsales_alb_sg" {
  vpc_id = aws_vpc.carsales_vpc.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name        = "CarSales ALB Security Group"
    Terraform   = "True"
  }
}

# Create Application Load Balancer

resource "aws_lb" "carsales_alb" {
  name               = "carsales-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.carsales_alb_sg.id]
  subnets = [
    aws_subnet.carsales-public-1a.id,
    aws_subnet.carsales-public-1b.id,
  ]
  enable_deletion_protection = false
  tags = {
    Name        = "CarSales Application Load Balancer"
    Terraform   = "True"
  }
}


resource "aws_lb_listener" "carsales_https" {
  load_balancer_arn = aws_lb.carsales_alb.arn
  port = 443
  protocol = "HTTPS"
 ssl_policy        = "ELBSecurityPolicy-TLS-1-0-2015-04"
  certificate_arn   = "arn:aws:acm:ap-south-1:207880003428:certificate/8a42034f-90c6-4c07-8dc7-f2fe2e6205bf"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.carsales-back-end-tg.arn
  }
}

resource "aws_lb_listener" "carsales_https_redirect" {
  load_balancer_arn = aws_lb.carsales_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener_rule" "carsales_test1_https" {
  listener_arn = aws_lb_listener.carsales_https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carsales-back-end-tg.arn
  }
    condition {
    path_pattern {
      values = ["/test1/"]
    }
  }
}


resource "aws_lb_listener_rule" "carsales_test2_https" {
  listener_arn = aws_lb_listener.carsales_https.arn
  priority     = 200
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.carsales-back-end-tg-2.arn
  }
    condition {
    path_pattern {
      values = ["/test2/"]
    }
  }
}

resource "aws_lb_target_group" "carsales-back-end-tg" {
  port = 80
  protocol = "HTTP"
  name = "carsales-back-end-target-group"
  vpc_id = aws_vpc.carsales_vpc.id
  stickiness {
    type = "lb_cookie"
    enabled = true
  }
  health_check {
    protocol = "HTTP"
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
  }
  tags = {
    Name        = "CarSales Back End Target Group"
    Terraform   = "True"
  }
}

resource "aws_lb_target_group" "carsales-back-end-tg-2" {
  name                 = "demo-http-blue"
  port                 = "3000"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.carsales_vpc.id
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
    interval            = 30
  }
}

