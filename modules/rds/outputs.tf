output "primary_db_endpoint" {
  value = aws_db_instance.blueops.endpoint
}

# output "replica_endpoints" {
#   value = [for i in aws_db_instance.blueops_replica : i.endpoint]
# }