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

# Enable the APIs a Gmail-reading service needs.
module "services" {
  source = "../../"

  project = var.project
  services = [
    "iam.googleapis.com",
    "gmail.googleapis.com",
  ]
}

output "enabled" {
  description = "Services now enabled on the project."
  value       = module.services.enabled_services
}
