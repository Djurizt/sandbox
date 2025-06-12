resource "aws_security_group" "rds_sg" {
  name        = format("%s-db-sg", var.common_tags["project"])
  description = "PostgreSQL security group"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = format("%s-db-sg", var.common_tags["project"])
  })
}