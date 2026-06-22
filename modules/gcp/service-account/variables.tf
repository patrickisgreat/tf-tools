variable "account_id" {
  description = "The service account id (the part before @). 6-30 lowercase letters, digits, or hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{4,28}[a-z0-9])$", var.account_id))
    error_message = "account_id must be 6-30 chars: start with a letter, then lowercase letters, digits, or hyphens."
  }
}

variable "display_name" {
  description = "Human-readable name for the service account."
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the service account."
  type        = string
  default     = null
}

variable "project" {
  description = "GCP project ID. Defaults to the provider's project when null."
  type        = string
  default     = null
}

variable "disabled" {
  description = "Create the service account in a disabled state."
  type        = bool
  default     = false
}

variable "project_roles" {
  description = "Project-level IAM roles to grant the service account, e.g. [\"roles/storage.objectViewer\"]."
  type        = list(string)
  default     = []
}

variable "create_key" {
  description = "Also create a JSON service account key. Avoid when possible; prefer workload identity / impersonation."
  type        = bool
  default     = false
}
