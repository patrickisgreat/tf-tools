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

# In a real config these come from aws/ecs-cluster and aws/ecs-service;
# placeholders keep the example self-contained for `terraform validate`.
variable "cluster_name" {
  description = "ECS cluster name."
  type        = string
  default     = "example"
}

variable "service_name" {
  description = "ECS service name."
  type        = string
  default     = "example-api"
}

module "scaling" {
  source = "../.."

  cluster_name = var.cluster_name
  service_name = var.service_name

  min_capacity = 1
  max_capacity = 4

  cpu_target_percent    = 50
  memory_target_percent = 70

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "policy_arns" {
  description = "Target-tracking policy ARNs by metric."
  value       = module.scaling.policy_arns
}
