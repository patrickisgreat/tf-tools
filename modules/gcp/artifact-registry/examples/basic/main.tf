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

module "images" {
  source = "../.."

  repository_id  = "example-services"
  location       = "us-central1"
  format         = "DOCKER"
  immutable_tags = true

  labels = {
    team = "platform"
    env  = "example"
  }
}

output "repository_url" {
  description = "Docker push/pull path for the example repository."
  value       = module.images.repository_url
}
