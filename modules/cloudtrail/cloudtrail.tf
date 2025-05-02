resource "aws_cloudtrail" "multi_region_trail" {
  name                          = format("%s-%s-cloudtrail", var.tags["environment"], var.tags["project"])
  s3_bucket_name                = data.aws_s3_bucket.central_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
  tags = var.tags
}