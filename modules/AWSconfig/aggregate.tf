resource "aws_config_configuration_aggregator" "aggregator" {
  name = "multi-region-aggregator"

  account_aggregation_source {
    account_ids = [data.aws_caller_identity.current.account_id]
    all_regions = true
  }
}

