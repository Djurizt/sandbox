resource "aws_config_configuration_recorder" "us_east_1" {
  provider = aws.state
  name     = "us-east-1-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "us_east_1" {
  provider       = aws.state
  name           = "us-east-1-config-channel"
  s3_bucket_name = data.aws_s3_bucket.central_bucket.bucket

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.us_east_1]
}

resource "aws_config_configuration_recorder_status" "us_east_1" {
  provider   = aws.state
  name       = aws_config_configuration_recorder.us_east_1.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us_east_1]
}

resource "aws_config_configuration_recorder" "us_east_2" {
  provider = aws.backup
  name     = "us-east-2-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "us_east_2" {
  provider       = aws.backup
  name           = "us-east-2-config-channel"
  s3_bucket_name = data.aws_s3_bucket.central_bucket.bucket

  snapshot_delivery_properties {
    delivery_frequency = "Twelve_Hours"
  }

  depends_on = [aws_config_configuration_recorder.us_east_2]
}

resource "aws_config_configuration_recorder_status" "us_east_2" {
  provider   = aws.backup
  name       = aws_config_configuration_recorder.us_east_2.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us_east_2]
}

resource "aws_config_configuration_recorder" "us_west_1" {
  provider = aws.alternate
  name     = "us-west-1-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "us_west_1" {
  provider       = aws.alternate
  name           = "us-west-1-config-channel"
  s3_bucket_name = data.aws_s3_bucket.central_bucket.bucket

  snapshot_delivery_properties {
    delivery_frequency = "Twelve_Hours"
  }

  depends_on = [aws_config_configuration_recorder.us_west_1]
}

resource "aws_config_configuration_recorder_status" "us_west_1" {
  provider   = aws.alternate
  name       = aws_config_configuration_recorder.us_west_1.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us_west_1]
}
