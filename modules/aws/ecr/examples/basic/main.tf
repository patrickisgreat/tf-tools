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

module "ecr" {
  source = "../.."

  name                       = "example-app"
  image_tag_mutability       = "IMMUTABLE"
  scan_on_push               = true
  keep_last_n_images         = 20
  expire_untagged_after_days = 7

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "repository_url" {
  description = "URL to docker push/pull the example repository."
  value       = module.ecr.repository_url
}
