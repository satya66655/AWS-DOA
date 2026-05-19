# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# Target Group 1: WRONG (Port 80) - causes failure for demo
resource "aws_lb_target_group" "wrong" {
  name        = "${var.project_name}-wrong-tg"
  port        = var.wrong_target_group_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-wrong-tg"
    Note = "WRONG target group - port 80 - app listens on 5000"
  }
}

# Target Group 2: CORRECT (Port 5000) - to use after fix
resource "aws_lb_target_group" "correct" {
  name        = "${var.project_name}-correct-tg"
  port        = var.correct_target_group_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    matcher             = "200"
    protocol            = "HTTP"
  }

  tags = {
    Name = "${var.project_name}-correct-tg"
    Note = "CORRECT target group - port 5000 - matches app"
  }
}

# ALB Listener (routes to WRONG target group initially)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wrong.arn
  }

  tags = {
    Name = "${var.project_name}-http-listener"
  }
}
