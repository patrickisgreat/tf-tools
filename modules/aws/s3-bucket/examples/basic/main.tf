terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

module "data" {
  source = "../.."

  bucket = "example-org-data-dev"

  lifecycle_rules = [
    {
      id              = "expire-tmp"
      prefix          = "tmp/"
      expiration_days = 30
    },
  ]

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "bucket_arn" {
  description = "ARN of the example bucket."
  value       = module.data.arn
}
