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

module "events" {
  source = "../.."

  name = "example-order-events"

  subscriptions = [
    {
      protocol = "email"
      endpoint = "alerts@example.com"
    },
  ]

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "topic_arn" {
  description = "ARN of the example topic."
  value       = module.events.arn
}
