resource "aws_dynamodb_table" "config_changes" {
  name           = format("%s-%s-aws_config_changes", var.tags["environment"], var.tags["project"])
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "resourceId"
  range_key    = "timestamp"
  attribute {
    name = "resourceId"
    type = "S"
  }
  attribute {
    name = "timestamp"
    type = "S"
  }
  server_side_encryption {
    enabled = true
  }
  point_in_time_recovery {
    enabled = true
  }
    ttl {
    attribute_name = "Expires"
    enabled        = true
  }
  lifecycle {
    prevent_destroy = false
  }
  tags = var.tags
}
