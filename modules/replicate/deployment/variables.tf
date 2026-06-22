variable "owner" {
  description = "Replicate account/owner that owns the deployment (your username or org). Must match the account behind the API token configured on the restapi provider."
  type        = string
}

variable "name" {
  description = "Deployment name (unique within the owner account)."
  type        = string
}

variable "model" {
  description = "Source model in \"owner/name\" form, e.g. \"stability-ai/sdxl\"."
  type        = string
}

variable "version_id" {
  description = "Pinned model version ID (the long hash). Pin it for reproducible deployments."
  type        = string
}

variable "hardware" {
  description = "Hardware SKU to run on, e.g. \"gpu-t4\", \"gpu-a40-small\", \"gpu-a100-large\"."
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances (0 allows scale-to-zero)."
  type        = number
  default     = 0

  validation {
    condition     = var.min_instances >= 0
    error_message = "min_instances must be >= 0."
  }
}

variable "max_instances" {
  description = "Maximum number of instances."
  type        = number
  default     = 1

  validation {
    condition     = var.max_instances >= 1
    error_message = "max_instances must be >= 1."
  }
}
