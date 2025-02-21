# Fetch the existing VPC by its tag name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc_2"] # Specify the VPC name (tag value) you want to match
  }
}
data "aws_security_group" "sg" {
 name = "jurist"
}
#Fetch public subnets dynamically based on provided tags
data "aws_subnets" "public_subnets" {
  filter {
    name   = "tag:Name"
    values = ["my-public-subnet-1", "my-public-subnet-2"] # Specify subnet names (tags)
  }

}
# Fetch the existing key pair
data "aws_key_pair" "existing_key" {
  key_name = "terra-key" # Use the existing key pair
}
# data "aws_lb_target_group" "yellow_group" {
#   name = "yellow-tg-2"
# }

# data "aws_lb_target_group" "jenkins_target_group" {
#   name = "blue-tg-2"
# }
# data "aws_lb" "alb" {
#   name = "my-alb-2" 
# }
# data "aws_route53_zone" "zone" {
#   name         = "thejurist.org.uk"
#   private_zone = false 
# }