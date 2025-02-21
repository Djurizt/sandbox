# resource "aws_security_group" "ec2_sg_2" {
#   name        = "ec2-sg-2"
#   description = "Allow traffic from ALB, SSH access, and all outbound traffic"
#   vpc_id      = data.aws_vpc.selected.id

#   # Allow traffic from ALB on ports 8081 (Blue) and 8082 (Yellow)
#   ingress {
#     from_port       = 8081
#     to_port         = 8081
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb_sg.id]
#   }

#   ingress {
#     from_port       = 8082
#     to_port         = 8082
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb_sg.id]
#   }

#   # Allow SSH for debugging
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # Restrict in production
#   }

#   # Allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
# }
# }