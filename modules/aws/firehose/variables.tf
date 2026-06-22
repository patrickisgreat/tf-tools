variable "name" {
  description = "Name of the Firehose delivery stream."
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role Firehose assumes to write to the destination bucket (and CloudWatch)."
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the destination S3 bucket."
  type        = string
}

variable "buffering_size" {
  description = "Buffer size in MB before delivery (1-128)."
  type        = number
  default     = 5
}

variable "buffering_interval" {
  description = "Buffer interval in seconds before delivery (0-900)."
  type        = number
  default     = 300
}

variable "compression_format" {
  description = "Compression for delivered objects."
  type        = string
  default     = "GZIP"

  validation {
    condition     = contains(["UNCOMPRESSED", "GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY"], var.compression_format)
    error_message = "compression_format must be one of UNCOMPRESSED, GZIP, ZIP, Snappy, HADOOP_SNAPPY."
  }
}

variable "prefix" {
  description = "Optional S3 prefix for delivered objects (supports partitioning expressions)."
  type        = string
  default     = null
}

variable "error_output_prefix" {
  description = "Optional S3 prefix for failed records."
  type        = string
  default     = null
}

variable "cloudwatch_logging_enabled" {
  description = "Enable CloudWatch logging of delivery errors."
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch log group name (required when cloudwatch_logging_enabled)."
  type        = string
  default     = null
}

variable "cloudwatch_log_stream_name" {
  description = "CloudWatch log stream name (required when cloudwatch_logging_enabled)."
  type        = string
  default     = null
}

variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption of the delivery stream."
  type        = bool
  default     = false
}

variable "sse_key_type" {
  description = "SSE key type: AWS_OWNED_CMK or CUSTOMER_MANAGED_CMK."
  type        = string
  default     = "AWS_OWNED_CMK"

  validation {
    condition     = contains(["AWS_OWNED_CMK", "CUSTOMER_MANAGED_CMK"], var.sse_key_type)
    error_message = "sse_key_type must be AWS_OWNED_CMK or CUSTOMER_MANAGED_CMK."
  }
}

variable "sse_key_arn" {
  description = "KMS key ARN (required when sse_key_type is CUSTOMER_MANAGED_CMK)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the delivery stream."
  type        = map(string)
  default     = {}
}
