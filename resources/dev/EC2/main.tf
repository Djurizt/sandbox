## Terraform block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.44.0"
    }
  }
}

provider "aws" {
  region = local.aws_region
}

# terraform {
#   backend "s3" {
#     bucket         = "dev-blueops-jurist-tf-state"
#     key            = "EC2/terraform.tfstate"
#     region         = "us-east-2"
#     dynamodb_table = "dev-blueops-jurist-tf-state-lock"
#     encrypt        = true
#   }
# }

locals {
  aws_region    = "us-east-1"
  instance_type = "t2.medium"
  key_pair      = "jurist"
  common_tags = {
    "id"             = "2025"
    "owner"          = "jurist"
    "environment"    = "development"
    "project"        = "blueops"
    "create_by"      = "Terraform"
    "cloud_provider" = "AWS"
    "company"        = "DEL"
  }
}

module "EC2" {
  source        = "../../../modules/EC2"
  aws_region    = local.aws_region
  instance_type = local.instance_type
  key_pair      = local.key_pair
  common_tags   = local.common_tags

}