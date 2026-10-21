variable "name" {
  description = "Name of the ECS cluster."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,255}$", var.name))
    error_message = "name may contain up to 255 letters, numbers, hyphens and underscores (ECS cluster naming rules)."
  }
}

variable "container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster (per-service CPU, memory, network and task metrics)."
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "Capacity providers to associate with the cluster. Services choose among these with a capacity_provider_strategy. Set to [] to associate none."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "Strategy used by services that do not set their own. Each entry's capacity_provider must be listed in capacity_providers."
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = []

  validation {
    condition = alltrue([
      for s in var.default_capacity_provider_strategy : contains(var.capacity_providers, s.capacity_provider)
    ])
    error_message = "Every capacity_provider in default_capacity_provider_strategy must also appear in capacity_providers."
  }
}

variable "execute_command_log_group_name" {
  description = "CloudWatch log group that records ECS Exec sessions. When null, sessions are not logged."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the cluster."
  type        = map(string)
  default     = {}
}
