terraform {
  required_version = ">= 1.6.0"

  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.19.0"
    }
  }
}

variable "replicate_api_token" {
  description = "Replicate API token. Pass via TF_VAR_replicate_api_token, never commit it."
  type        = string
  sensitive   = true
}

variable "owner" {
  description = "Replicate account/owner."
  type        = string
}

provider "restapi" {
  uri                  = "https://api.replicate.com"
  write_returns_object = true

  headers = {
    Authorization = "Token ${var.replicate_api_token}"
    Content-Type  = "application/json"
  }
}

module "sdxl" {
  source = "../.."

  owner         = var.owner
  name          = "sdxl-example"
  model         = "stability-ai/sdxl"
  version_id    = "7762fd07cf82c948538e41f63f77d685e02b063e37e496e96eefd46c929f9bdc"
  hardware      = "gpu-a40-large"
  min_instances = 0
  max_instances = 1
}

output "endpoint" {
  description = "Prediction endpoint for the example deployment."
  value       = module.sdxl.endpoint
}
