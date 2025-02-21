# Target group for Blue application (Port 8081)
resource "aws_lb_target_group" "blue_tg" {
  name     = "blue-tg-3"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Target group for Yellow application (Port 8082)
resource "aws_lb_target_group" "yellow_tg" {
  name     = "yellow-tg-3"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    path                = "/yellow"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Register Instances with Target Groups
resource "aws_lb_target_group_attachment" "blue" {
  target_group_arn = aws_lb_target_group.blue_tg.arn
  target_id        = aws_instance.blue.id
}

resource "aws_lb_target_group_attachment" "yellow" {
  target_group_arn = aws_lb_target_group.yellow_tg.arn
  target_id        = aws_instance.yellow.id
}