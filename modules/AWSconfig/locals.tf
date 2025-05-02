# locals {
#   region_providers = {
#     "us-east-1" = aws.state
#     "us-east-2" = aws.backup
#     "us-west-1" = aws.alternate
#   }

#   config_name  = format("%s-%s-aws_config_recorder", var.tags["environment"], var.tags["project"])
#   channel_name = format("%s-%s-aws_config_delivery", var.tags["environment"], var.tags["project"])
# }