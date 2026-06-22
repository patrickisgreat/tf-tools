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

module "task_role" {
  source = "../.."

  name                  = "example-orders-task-role"
  trusted_role_services = ["ecs-tasks.amazonaws.com"]

  inline_policies = {
    s3-read = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::example-bucket/*"]
      }]
    })
  }

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "role_arn" {
  description = "ARN of the example role."
  value       = module.task_role.arn
}
