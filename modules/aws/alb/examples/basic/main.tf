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

# In a real config these come from a VPC module; placeholders keep the example
# self-contained for `terraform validate`.
variable "vpc_id" {
  description = "VPC id."
  type        = string
  default     = "vpc-0123456789abcdef0"
}

variable "subnet_ids" {
  description = "Public subnets for the load balancer."
  type        = list(string)
  default     = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]
}

module "alb" {
  source = "../.."

  name       = "example-api"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  target_port  = 8080
  health_check = { path = "/health" }

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "dns_name" {
  description = "Hostname of the example load balancer."
  value       = module.alb.dns_name
}

output "target_group_arn" {
  description = "Target group to register services with."
  value       = module.alb.target_group_arn
}
