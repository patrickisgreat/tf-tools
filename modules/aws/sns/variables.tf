variable "name" {
  description = "Name of the SNS topic. FIFO topics must end in \".fifo\"."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+(\\.fifo)?$", var.name))
    error_message = "name may contain alphanumerics, hyphens, and underscores (and end in .fifo for FIFO topics)."
  }
}

variable "display_name" {
  description = "Display name for the topic (used as the From name for SMS/email)."
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Create a FIFO topic. The name must end in \".fifo\"."
  type        = bool
  default     = false

  validation {
    condition     = !var.fifo_topic || endswith(var.name, ".fifo")
    error_message = "FIFO topics require a name ending in \".fifo\"."
  }
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication (FIFO topics only)."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS key id/alias/ARN for server-side encryption. Defaults to the AWS-managed SNS key. Set to null to disable encryption at rest."
  type        = string
  default     = "alias/aws/sns"
}

variable "delivery_policy" {
  description = "Optional topic delivery policy as a JSON string (retry/backoff settings)."
  type        = string
  default     = null
}

variable "policy" {
  description = "Optional topic access policy as a JSON string (e.g. allow a service or account to publish)."
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "Subscriptions to attach to the topic."
  type = list(object({
    protocol             = string # sqs, lambda, https, http, email, email-json, sms, application, firehose
    endpoint             = string
    raw_message_delivery = optional(bool, false)
    filter_policy        = optional(string)
    filter_policy_scope  = optional(string) # MessageAttributes or MessageBody
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the topic."
  type        = map(string)
  default     = {}
}
