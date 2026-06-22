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

module "events" {
  source = "../.."

  name = "example-order-events"

  subscriptions = [
    {
      name                 = "example-order-events-worker"
      ack_deadline_seconds = 30
    },
  ]

  labels = {
    team = "platform"
    env  = "example"
  }
}

output "topic_id" {
  description = "ID of the example topic."
  value       = module.events.topic_id
}
