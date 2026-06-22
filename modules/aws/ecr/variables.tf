variable "name" {
  description = "Name of the ECR repository (e.g. \"team/service\")."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9._/-]*[a-z0-9])?$", var.name))
    error_message = "name must be lowercase alphanumeric and may contain . _ / - (ECR naming rules)."
  }
}

variable "image_tag_mutability" {
  description = "Tag mutability: MUTABLE or IMMUTABLE."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Scan images for vulnerabilities on push."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type: AES256 or KMS."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be AES256 or KMS."
  }
}

variable "kms_key" {
  description = "ARN of the KMS key to use when encryption_type is KMS. When null, AWS uses the default ECR-managed key."
  type        = string
  default     = null
}

variable "force_delete" {
  description = "Allow Terraform to delete the repository even if it still contains images."
  type        = bool
  default     = false
}

variable "keep_last_n_images" {
  description = "Lifecycle helper: keep only the most recent N images. Set to 0 to disable this rule."
  type        = number
  default     = 30

  validation {
    condition     = var.keep_last_n_images >= 0
    error_message = "keep_last_n_images must be >= 0."
  }
}

variable "expire_untagged_after_days" {
  description = "Lifecycle helper: expire untagged images older than N days. Set to 0 to disable this rule."
  type        = number
  default     = 14

  validation {
    condition     = var.expire_untagged_after_days >= 0
    error_message = "expire_untagged_after_days must be >= 0."
  }
}

variable "lifecycle_policy" {
  description = "Raw ECR lifecycle policy JSON. When set, it overrides the keep_last_n_images / expire_untagged_after_days helpers entirely."
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "Optional ECR repository policy JSON (e.g. to grant cross-account pull access)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the repository."
  type        = map(string)
  default     = {}
}
