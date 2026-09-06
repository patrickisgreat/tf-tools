variable "services" {
  description = "Service APIs to enable, by hostname, e.g. [\"gmail.googleapis.com\"]."
  type        = list(string)

  validation {
    condition     = length(var.services) > 0
    error_message = "services must not be empty."
  }

  validation {
    condition = alltrue([
      for s in var.services : can(regex("^[a-z0-9][a-z0-9.-]*\\.googleapis\\.com$", s))
    ])
    error_message = "Each service must be an API hostname ending in .googleapis.com, e.g. gmail.googleapis.com."
  }
}

variable "project" {
  description = "GCP project ID. Defaults to the provider's project when null."
  type        = string
  default     = null
}

variable "disable_on_destroy" {
  description = "Disable the API when this resource is destroyed. Defaults to false: disabling a project-wide API can break unrelated workloads."
  type        = bool
  default     = false
}

variable "disable_dependent_services" {
  description = "Also disable services that depend on these. Defaults to false; enabling it makes a destroy cascade across the project."
  type        = bool
  default     = false
}
