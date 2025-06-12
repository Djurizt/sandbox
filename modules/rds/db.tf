resource "aws_db_instance" "blueops" {
  identifier        = var.db_id
  instance_class    = var.db_instance
  allocated_storage = var.db_storage
  max_allocated_storage = var.max_storage
  engine            = var.db_type
  engine_version    = var.db_version
  db_name           = var.db_name
  username = jsondecode(data.aws_secretsmanager_secret_version.db_secrets_versions.secret_string).db_username
  password = jsondecode(data.aws_secretsmanager_secret_version.db_secrets_versions.secret_string).db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  multi_az = var.multi_az
  storage_type = var.storage_type
  backup_retention_period = var.backup_retention_period
  backup_window = var.backup_window
  maintenance_window      = var.maintenance_window
  parameter_group_name   = aws_db_parameter_group.blueops.name
  publicly_accessible    = var.db_access
  skip_final_snapshot    = var.db_snapshot
  final_snapshot_identifier = "${var.common_tags["project"]}db-final-snapshot"
  performance_insights_enabled = var.performance_insights
  performance_insights_retention_period = var.insights_retention_period
  monitoring_interval     = var.monitoring_interval
  monitoring_role_arn     = aws_iam_role.rds_monitoring_role.arn
  deletion_protection     = var.deletion_protection
  auto_minor_version_upgrade = true
  apply_immediately       = var.apply_immediately
  

  tags = merge(var.common_tags, {
    Name = format("%s-%s-%s-db", var.common_tags["environment"], var.common_tags["project"], var.common_tags["owner"])
  })
}

