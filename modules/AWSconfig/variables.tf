variable "regions" {
  type        = list(string)
  description = "List of AWS regions"
}
variable "config" {
  type = object({
    aws_region_main      = string
    aws_region_backup    = string
    aws_region_alternate = string
  })
  description = "Configuration map for providers"
}
variable "central_region" {
  description = "Region where centralized S3 bucket and aggregator are created"
  type        = string
}
variable "tags" {
  type        = map(string)
  description = "A map of key-value pairs representing common tags to apply to AWS resources (such as Name, Environment). Tags help in organizing and identifying resources, especially in large-scale environments."
}
variable "delivery_frequency" {
  type        = string
  description = "Snapshot delivery frequency"
}