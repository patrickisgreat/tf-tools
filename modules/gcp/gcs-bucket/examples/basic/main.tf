terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

variable "project" {
  description = "GCP project ID."
  type        = string
  default     = "example-project"
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

module "bucket" {
  source = "../.."

  name               = "example-project-data"
  location           = "US"
  versioning_enabled = true

  lifecycle_rules = [
    {
      action    = { type = "SetStorageClass", storage_class = "NEARLINE" }
      condition = { age = 30 }
    },
    {
      action    = { type = "Delete" }
      condition = { age = 365 }
    },
  ]

  labels = {
    team = "platform"
    env  = "example"
  }
}

output "bucket_url" {
  description = "Base gs:// URL of the example bucket."
  value       = module.bucket.url
}
