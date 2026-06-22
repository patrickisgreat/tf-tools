variable "name" {
  description = "Name of the IAM role."
  type        = string
}

variable "path" {
  description = "Path for the role."
  type        = string
  default     = "/"
}

variable "description" {
  description = "Description of the role."
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "Full trust policy JSON. When set, it overrides trusted_role_services / trusted_role_arns entirely."
  type        = string
  default     = null
}

variable "trusted_role_services" {
  description = "Service principals allowed to assume the role, e.g. [\"ecs-tasks.amazonaws.com\"]. Used to build the trust policy when assume_role_policy is null."
  type        = list(string)
  default     = []
}

variable "trusted_role_arns" {
  description = "AWS principal ARNs allowed to assume the role (accounts/roles). Used to build the trust policy when assume_role_policy is null."
  type        = list(string)
  default     = []
}

variable "managed_policy_arns" {
  description = "ARNs of managed policies to attach to the role."
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Inline policies as a map of name => policy JSON."
  type        = map(string)
  default     = {}
}

variable "permissions_boundary" {
  description = "ARN of a policy used as the permissions boundary for the role."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum CLI/API session duration in seconds (3600-43200)."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "force_detach_policies" {
  description = "Force detaching any policies the role has before destroying it."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the role."
  type        = map(string)
  default     = {}
}
