variable "name" {
  description = "Globally-unique bucket name."
  type        = string
}

variable "project" {
  description = "GCP project ID. Defaults to the provider's project when null."
  type        = string
  default     = null
}

variable "location" {
  description = "Bucket location: a region (US-CENTRAL1) or multi-region (US, EU)."
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Default storage class."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "storage_class must be STANDARD, NEARLINE, COLDLINE, or ARCHIVE."
  }
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access (recommended; disables object ACLs)."
  type        = bool
  default     = true
}

variable "public_access_prevention" {
  description = "Public access prevention: 'enforced' or 'inherited'."
  type        = string
  default     = "enforced"

  validation {
    condition     = contains(["enforced", "inherited"], var.public_access_prevention)
    error_message = "public_access_prevention must be 'enforced' or 'inherited'."
  }
}

variable "versioning_enabled" {
  description = "Enable object versioning."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow Terraform to destroy the bucket even if it contains objects."
  type        = bool
  default     = false
}

variable "kms_key_name" {
  description = "Optional CMEK key for default encryption (projects/.../cryptoKeys/...)."
  type        = string
  default     = null
}

variable "lifecycle_rules" {
  description = "Object lifecycle rules. Each has an action and a condition."
  type = list(object({
    action = object({
      type          = string           # "Delete" or "SetStorageClass"
      storage_class = optional(string) # required when type = "SetStorageClass"
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string) # RFC3339 date, e.g. "2030-01-01"
      with_state            = optional(string) # "LIVE", "ARCHIVED", or "ANY"
      matches_storage_class = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  default = []
}

variable "labels" {
  description = "Labels to apply to the bucket."
  type        = map(string)
  default     = {}
}
