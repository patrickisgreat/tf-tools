variable "cluster_name" {
  description = "Name of the ECS cluster the service runs in."
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service to scale."
  type        = string
}

variable "min_capacity" {
  description = "Lower bound on running tasks. The autoscaler never scales in below this."
  type        = number
  default     = 1

  validation {
    condition     = var.min_capacity >= 0
    error_message = "min_capacity must be zero or greater."
  }
}

variable "max_capacity" {
  description = "Upper bound on running tasks. Must be at least min_capacity."
  type        = number
  default     = 4

  validation {
    condition     = var.max_capacity >= var.min_capacity
    error_message = "max_capacity must be greater than or equal to min_capacity."
  }
}

variable "cpu_target_percent" {
  description = "Average CPU utilisation to hold the service at. null disables the CPU policy."
  type        = number
  default     = 50

  validation {
    condition     = var.cpu_target_percent == null || (var.cpu_target_percent > 0 && var.cpu_target_percent <= 100)
    error_message = "cpu_target_percent must be between 1 and 100, or null to disable."
  }
}

variable "memory_target_percent" {
  description = "Average memory utilisation to hold the service at. null disables the memory policy."
  type        = number
  default     = null

  validation {
    condition     = var.memory_target_percent == null || (var.memory_target_percent > 0 && var.memory_target_percent <= 100)
    error_message = "memory_target_percent must be between 1 and 100, or null to disable."
  }
}

variable "requests_per_target" {
  description = "ALB requests per task per minute to hold the service at. Needs alb_arn_suffix and target_group_arn_suffix. null disables the request-count policy."
  type        = number
  default     = null

  validation {
    condition     = var.requests_per_target == null || (var.alb_arn_suffix != null && var.target_group_arn_suffix != null)
    error_message = "requests_per_target needs alb_arn_suffix and target_group_arn_suffix so that the ALBRequestCountPerTarget metric can be resolved."
  }
}

variable "alb_arn_suffix" {
  description = "arn_suffix of the application load balancer in front of the service. Only used with requests_per_target."
  type        = string
  default     = null
}

variable "target_group_arn_suffix" {
  description = "arn_suffix of the target group the service registers with. Only used with requests_per_target."
  type        = string
  default     = null
}

variable "scale_out_cooldown" {
  description = "Seconds to wait after a scale-out before another scale-out can start."
  type        = number
  default     = 60
}

variable "scale_in_cooldown" {
  description = "Seconds to wait after a scale-in before another scale-in can start. Longer than scale-out so that bursts are not followed by a premature scale-in."
  type        = number
  default     = 300
}

variable "disable_scale_in" {
  description = "Only ever scale out. Useful during a migration, or for a worker whose backlog must drain."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the scaling target."
  type        = map(string)
  default     = {}
}
