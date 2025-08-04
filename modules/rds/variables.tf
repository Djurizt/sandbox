variable "aws_region" {
  type = string
}

variable "db_instance" {
  type = string
}

variable "db_id" {
  type = string
}
variable "db_storage" {
  type = number
}
variable "db_type" {
  type = string
}
variable "db_version" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_family" {
  type = string
}
variable "db_access" {
  type = bool
}
variable "db_snapshot" {
  type = bool
}
variable "common_tags" {
  type = map(any)
}

variable "db_parameters" {
  type = map(any)
}
variable "max_storage" {
  type = number
}
variable "key_deletion" {
  type = number
}
variable "key_rotation" {
  type = bool
}
# variable "rds_monitoring" {
#   type        = string
# }
variable "backup_window" {
  type = string
}
variable "backup_retention_period" {
  type = number
}
variable "maintenance_window" {
  type = string
}
variable "performance_insights" {
  type = bool
}
variable "insights_retention_period" {
  type = number
}
variable "monitoring_interval" {
  type = number
}
variable "deletion_protection" {
  type = bool
}
variable "multi_az" {
  type = bool
}
variable "storage_type" {
  type = string
}
variable "allowed_cidrs" {
  type = list(string)
}
variable "apply_immediately" {
  type = bool
}