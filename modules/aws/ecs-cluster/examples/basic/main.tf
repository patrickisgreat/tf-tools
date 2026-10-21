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

module "cluster" {
  source = "../.."

  name = "example"

  default_capacity_provider_strategy = [
    { capacity_provider = "FARGATE", weight = 1, base = 1 },
    { capacity_provider = "FARGATE_SPOT", weight = 3 },
  ]

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "cluster_arn" {
  description = "ARN of the example cluster."
  value       = module.cluster.arn
}
