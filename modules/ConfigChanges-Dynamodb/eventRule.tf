resource "aws_cloudwatch_event_rule" "config_changes" {
  name        = format("%s-%s-aws_config_changes_rule", var.tags["environment"], var.tags["project"])
  description = "Trigger Lambda on AWS Config changes"
  event_pattern = jsonencode({
    source = ["aws.config"],
    "detail-type" = ["Config Configuration Item Change"]
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.config_changes.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.config_logger.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.config_logger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.config_changes.arn
}
