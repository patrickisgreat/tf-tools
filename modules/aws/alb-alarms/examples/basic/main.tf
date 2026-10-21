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

# In a real config these come from aws/alb and aws/sns; placeholders keep the
# example self-contained for `terraform validate`.
variable "load_balancer_arn_suffix" {
  description = "ALB arn_suffix."
  type        = string
  default     = "app/example/0123456789abcdef"
}

variable "target_group_arn_suffix" {
  description = "Target group arn_suffix."
  type        = string
  default     = "targetgroup/example/0123456789abcdef"
}

variable "alerts_topic_arn" {
  description = "SNS topic to notify."
  type        = string
  default     = "arn:aws:sns:us-east-1:123456789012:example-alerts"
}

module "alarms" {
  source = "../.."

  name                     = "example-api"
  load_balancer_arn_suffix = var.load_balancer_arn_suffix
  target_group_arn_suffix  = var.target_group_arn_suffix
  alarm_actions            = [var.alerts_topic_arn]
  runbook_url              = "https://example.com/runbooks/example-api"

  tags = {
    Team        = "platform"
    Environment = "example"
  }
}

output "alarm_arns" {
  description = "ARNs of the alarms, by key."
  value       = module.alarms.alarm_arns
}
