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

# In a real config these would come from the aws/s3-bucket and aws/iam-role modules.
variable "role_arn" {
  description = "Firehose delivery IAM role ARN."
  type        = string
  default     = "arn:aws:iam::123456789012:role/example-firehose-role"
}

variable "bucket_arn" {
  description = "Destination bucket ARN."
  type        = string
  default     = "arn:aws:s3:::example-events-bucket"
}

module "firehose" {
  source = "../.."

  name       = "example-events-to-s3"
  role_arn   = var.role_arn
  bucket_arn = var.bucket_arn

  buffering_size     = 64
  compression_format = "GZIP"
  prefix             = "events/"

  tags = {
    Team        = "data"
    Environment = "example"
  }
}

output "delivery_stream_arn" {
  description = "ARN of the example delivery stream."
  value       = module.firehose.arn
}
