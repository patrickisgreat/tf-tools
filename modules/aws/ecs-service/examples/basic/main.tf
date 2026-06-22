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

# In a real config these come from a VPC/cluster module; placeholders keep the example
# self-contained for `terraform validate`.
variable "cluster_arn" {
  description = "ECS cluster ARN."
  type        = string
  default     = "arn:aws:ecs:us-east-1:123456789012:cluster/example"
}

variable "subnet_ids" {
  description = "Subnets for the service."
  type        = list(string)
  default     = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]
}

module "api" {
  source = "../.."

  name        = "example-api"
  cluster_arn = var.cluster_arn

  cpu    = "256"
  memory = "512"

  container_definitions = jsonencode([
    {
      name         = "app"
      image        = "nginx:latest"
      essential    = true
      portMappings = [{ containerPort = 80, protocol = "tcp" }]
    }
  ])

  subnet_ids       = var.subnet_ids
  assign_public_ip = true

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "service_name" {
  description = "Name of the example service."
  value       = module.api.service_name
}
