resource "aws_lambda_function" "config_logger" {
  function_name = format("%s-%s-aws_config_dynamodb", var.tags["environment"], var.tags["project"])
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.config_changes.name
    }
  }
}