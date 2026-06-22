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

module "dlq" {
  source = "../.."

  name                      = "example-orders-dlq"
  message_retention_seconds = 1209600
}

module "orders" {
  source = "../.."

  name                       = "example-orders"
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20

  dead_letter_target_arn = module.dlq.arn
  max_receive_count      = 5

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "queue_url" {
  description = "URL of the example orders queue."
  value       = module.orders.url
}
