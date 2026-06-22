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

module "app_sa" {
  source = "../.."

  account_id   = "example-orders-app"
  display_name = "Example orders application"

  project_roles = [
    "roles/storage.objectViewer",
  ]
}

output "service_account_email" {
  description = "Email of the example service account."
  value       = module.app_sa.email
}
