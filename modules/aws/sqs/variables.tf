variable "name" {
  description = "Name of the queue. FIFO queues must end in \".fifo\"."
  type        = string
}

variable "fifo_queue" {
  description = "Create a FIFO queue. The name must end in \".fifo\"."
  type        = bool
  default     = false

  validation {
    condition     = !var.fifo_queue || endswith(var.name, ".fifo")
    error_message = "FIFO queues require a name ending in \".fifo\"."
  }
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication (FIFO queues only)."
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout (0-43200)."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "How long messages are retained (60-1209600)."
  type        = number
  default     = 345600
}

variable "max_message_size" {
  description = "Maximum message size in bytes (1024-262144)."
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Delivery delay for messages (0-900)."
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Long-polling wait time on receive (0-20)."
  type        = number
  default     = 0
}

variable "sqs_managed_sse_enabled" {
  description = "Enable SSE-SQS (AWS-managed encryption). Ignored when kms_master_key_id is set."
  type        = bool
  default     = true
}

variable "kms_master_key_id" {
  description = "KMS key id/alias/ARN for SSE-KMS. When set, takes precedence over sqs_managed_sse_enabled."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "Seconds SQS can reuse a KMS data key (60-86400). Only used with kms_master_key_id."
  type        = number
  default     = 300
}

variable "dead_letter_target_arn" {
  description = "ARN of a dead-letter queue. When set, a redrive policy is attached."
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Receives before a message moves to the dead-letter queue (used with dead_letter_target_arn)."
  type        = number
  default     = 5
}

variable "redrive_allow_policy" {
  description = "Optional redrive allow policy JSON (controls which source queues may use this queue as a DLQ)."
  type        = string
  default     = null
}

variable "policy" {
  description = "Optional queue access policy as a JSON string."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the queue."
  type        = map(string)
  default     = {}
}
