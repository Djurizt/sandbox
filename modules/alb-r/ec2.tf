# EC2 Instances
resource "aws_instance" "blue" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.public_subnets.ids[0] # Use the first subnet ID from the filtered subnets
  vpc_security_group_ids = [data.aws_security_group.sg.id]
  key_name               = "terra-key"
  user_data              = file("${path.module}/yellow.sh")

  tags = {
    Name    = "blue-app"
    Project = "blue-app"
  }
}

resource "aws_instance" "yellow" {
  ami                    = "ami-04b4f1a9cf54c11d0"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.public_subnets.ids[1] # Use the second subnet ID from the filtered subnets
  key_name               = "terra-key"
  vpc_security_group_ids = [data.aws_security_group.sg.id]
  user_data              = file("${path.module}/yellow.sh")

  tags = {
    Name    = "yellow-app"
    Project = "yellow-app"
  }
}


# resource "aws_route53_record" "blue_cname" {
#   zone_id = data.aws_route53_zone.zone.zone_id
#   name    = "blue"
#   type    = var.record_type
#   ttl     = var.record_ttl
#   records = [data.aws_lb.alb.dns_name]
# }
# resource "aws_route53_record" "yellow_cname" {
#   zone_id = data.aws_route53_zone.zone.zone_id
#   name    = "yellow"
#   type    = var.record_type
#   ttl     = var.record_ttl
#   records = [data.aws_lb.alb.dns_name]
# }