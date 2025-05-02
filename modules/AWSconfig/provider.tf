terraform {
  required_version = ">= 1.10.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias  = "state"
  region = "us-east-1"
}

provider "aws" {
  alias  = "backup"
  region = var.config.aws_region_backup
}

provider "aws" {
  alias  = "alternate"
  region = var.config.aws_region_alternate
}

