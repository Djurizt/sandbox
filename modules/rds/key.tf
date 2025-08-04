resource "aws_kms_key" "rds" {
  description             = "KMS key for encrypting RDS PostgreSQL database"
  deletion_window_in_days = var.key_deletion
  enable_key_rotation     = var.key_rotation

  tags = merge(var.common_tags, {
    Name = format("%s-%s-%s-kms", var.common_tags["environment"], var.common_tags["project"], var.common_tags["owner"])
  })
}

resource "aws_kms_alias" "rds" {
  name          = "alias/rds-encryption-key"
  target_key_id = aws_kms_key.rds.key_id
}
