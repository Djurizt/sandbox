resource "aws_lb" "main" {
  # depends_on         = [aws_security_group.alb_sg]
  name               = format("%s-%s-%s-alb", var.common_tags["environment"], var.common_tags["owner"], var.common_tags["project"])
  internal           = var.is_it_internal
  load_balancer_type = var.lb_type
  # security_groups    = [aws_security_group.alb_sg.id]
  security_groups    = [data.aws_security_group.sg.id]
  subnets            = var.public_subnets

  enable_deletion_protection = var.delete_lb_protection

  tags = merge(var.common_tags, {
    Name = format("%s-%s-%s-alb", var.common_tags["environment"], var.common_tags["owner"], var.common_tags["project"])
  })
}

resource "aws_lb_listener" "dynamic_listener" {
  for_each = {
    http  = { port = 80,  protocol = "HTTP",  action_type = "redirect" }
    https = { port = 443, protocol = "HTTPS", action_type = "forward" }
  }
  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = each.value.protocol

  dynamic "default_action" {
    for_each = [each.value.action_type]
    content {
      type = each.value.action_type

      dynamic "redirect" {
        for_each = each.value.action_type == "redirect" ? [1] : []
        content {
          host        = "#{host}"
          path        = "/"
          port        = "443"
          protocol    = "HTTPS"
          query       = "#{query}"
          status_code = "HTTP_301"
        }
      }

      dynamic "forward" {
        for_each = each.value.action_type == "forward" ? [1] : []
        content {
          target_group {
            arn = aws_lb_target_group.groups["green-tg"].arn
          }
        }
      }
    }
  }

  ssl_policy      = each.value.protocol == "HTTPS" ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn = each.value.protocol == "HTTPS" ? data.aws_acm_certificate.domain_cert.arn : null
}
resource "aws_lb_listener_rule" "dynamic" {
  for_each = { for rule in var.rules : rule.priority => rule }

  listener_arn = aws_lb_listener.dynamic_listener[each.value.protocol].arn
  priority     = each.value.priority

  condition {
    host_header {
      values = [each.value.host_header]
    }
  }

  action {
    type             = var.rules_type
    target_group_arn = aws_lb_target_group.groups[each.value.target_group_arn].arn
  }
}
resource "aws_lb_target_group" "groups" {
  for_each = { for tg in var.target_groups : tg.name => tg }

  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = data.aws_vpc.main.id
  target_type = each.value.target_type

  health_check {
    path                = each.value.health_check_path
    interval            = each.value.health_check_interval
    timeout             = each.value.health_check_timeout
    healthy_threshold   = each.value.healthy_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
  }

  tags = merge(var.common_tags, { Name = each.value.name })
}
