data "aws_s3_bucket" "central_bucket" {
  provider = aws.state
  bucket = "development-connect-sandbox-tf-state"
}
data "aws_dynamodb_table" "db_table" {
  provider = aws.state
  name = "development-connect-sandbox-tf-state-lock"
}