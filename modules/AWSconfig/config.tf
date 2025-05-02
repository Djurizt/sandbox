# resource "aws_config_configuration_recorder" "config_recorder" {
#   for_each = toset(var.regions)
#   provider = local.region_providers[each.key]
#   name     = format("%s-%s-aws_config_recorder", var.tags["environment"], var.tags["project"])
#   role_arn = aws_iam_role.config_role.arn

#   recording_group {
#     all_supported                 = true
#     include_global_resource_types = true
#   }
# }

# resource "aws_config_delivery_channel" "config_channel" {
#   for_each = toset(var.regions)
#   provider = local.region_providers[each.key]
#   name           = format("%s-%s-aws_config_delivery", var.tags["environment"], var.tags["project"])
#   s3_bucket_name = data.aws_s3_bucket.central_bucket.bucket
#   snapshot_delivery_properties {
#     delivery_frequency = "Twelve_Hours"
#   }
#   depends_on = [aws_config_configuration_recorder.config_recorder]
# }

# resource "aws_config_configuration_recorder_status" "config_status" {
#   for_each = toset(var.regions)
#   provider = local.region_providers[each.key]
#   name       = aws_config_configuration_recorder.config_recorder[each.key].name
#   is_enabled = true
#   depends_on = [aws_config_delivery_channel.config_channel]
# }

