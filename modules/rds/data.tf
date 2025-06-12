data "aws_vpc" "vpc" {
  filter {
    name   = "is-default"
    values = ["true"]
  }

  # filter {
  #   name   = "tag:environment"
  #   values = ["dev"]
  # }
}
data "aws_secretsmanager_secret" "db_secrets" {
  name     = "EKS_DB"
}

data "aws_secretsmanager_secret_version" "db_secrets_versions" {
  secret_id  = data.aws_secretsmanager_secret.db_secrets.id
}