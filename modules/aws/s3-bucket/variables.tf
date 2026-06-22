variable "bucket" {
  description = "Globally-unique bucket name."
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete a non-empty bucket."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Default server-side encryption: AES256 or aws:kms."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be AES256 or aws:kms."
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN to use when sse_algorithm is aws:kms. When null, the AWS-managed S3 key is used."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Use an S3 Bucket Key to reduce KMS request costs (recommended with aws:kms)."
  type        = bool
  default     = true
}

variable "block_public_access" {
  description = "Apply a public access block that denies all public access."
  type        = bool
  default     = true
}

variable "object_ownership" {
  description = "Object ownership: BucketOwnerEnforced (disables ACLs), BucketOwnerPreferred, or ObjectWriter."
  type        = string
  default     = "BucketOwnerEnforced"

  validation {
    condition     = contains(["BucketOwnerEnforced", "BucketOwnerPreferred", "ObjectWriter"], var.object_ownership)
    error_message = "object_ownership must be BucketOwnerEnforced, BucketOwnerPreferred, or ObjectWriter."
  }
}

variable "lifecycle_rules" {
  description = "Object lifecycle rules."
  type = list(object({
    id                                 = string
    enabled                            = optional(bool, true)
    prefix                             = optional(string, "")
    expiration_days                    = optional(number)
    noncurrent_version_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  default = []
}

variable "policy" {
  description = "Optional bucket policy as a JSON string."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the bucket."
  type        = map(string)
  default     = {}
}
