resource "aws_db_parameter_group" "blueops" {
  name   = var.db_id
  family = var.db_family
  # postgres_parameters = yamldecode(file("${path.module}/rds_postgres_parameters.yaml"))

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.key
      value = parameter.value
      apply_method = "pending-reboot"
    }
  }
}
