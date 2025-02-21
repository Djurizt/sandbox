output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "blue_instance_id" {
  description = "Instance ID of the Blue EC2 instance"
  value       = aws_instance.blue.id
}

output "yellow_instance_id" {
  description = "Instance ID of the Yellow EC2 instance"
  value       = aws_instance.yellow.id
}

output "blue_target_group_arn" {
  description = "ARN of the Blue Target Group"
  value       = aws_lb_target_group.blue_tg.arn
}

output "yellow_target_group_arn" {
  description = "ARN of the Yellow Target Group"
  value       = aws_lb_target_group.yellow_tg.arn
}