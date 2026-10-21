variable "name" {
  description = "Prefix for the alarm names, typically <service>-<environment>."
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "arn_suffix of the application load balancer (the LoadBalancer metric dimension)."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "arn_suffix of the target group (the TargetGroup metric dimension)."
  type        = string
}

variable "alarm_actions" {
  description = "ARNs notified when an alarm enters ALARM, usually an SNS topic from aws/sns."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "ARNs notified when an alarm returns to OK. Defaults to alarm_actions so that recoveries are announced too."
  type        = list(string)
  default     = null
}

variable "period_seconds" {
  description = "Length of each evaluation period."
  type        = number
  default     = 60
}

variable "error_rate_threshold_percent" {
  description = "Percentage of requests answered with HTTP 5xx by the targets that triggers the error-rate alarm. null disables it."
  type        = number
  default     = 5

  validation {
    condition     = var.error_rate_threshold_percent == null || (var.error_rate_threshold_percent >= 0 && var.error_rate_threshold_percent <= 100)
    error_message = "error_rate_threshold_percent must be between 0 and 100, or null to disable the alarm."
  }
}

variable "error_rate_evaluation_periods" {
  description = "Consecutive periods the error rate must breach before alarming."
  type        = number
  default     = 2
}

variable "latency_threshold_seconds" {
  description = "Target response time that triggers the latency alarm. null disables it."
  type        = number
  default     = 3
}

variable "latency_statistic" {
  description = "Statistic of TargetResponseTime to compare: a percentile such as p95 or p99, or Average."
  type        = string
  default     = "p95"

  validation {
    condition     = var.latency_statistic == "Average" || can(regex("^p[0-9]{1,2}(\\.[0-9]+)?$", var.latency_statistic))
    error_message = "latency_statistic must be Average or a percentile such as p95 or p99.9."
  }
}

variable "latency_evaluation_periods" {
  description = "Consecutive periods the latency must breach before alarming."
  type        = number
  default     = 2
}

variable "unhealthy_host_threshold" {
  description = "Number of unhealthy targets at which the unhealthy-hosts alarm fires. null disables it."
  type        = number
  default     = 1
}

variable "treat_missing_data" {
  description = "How to treat periods with no data: notBreaching, breaching, ignore or missing. notBreaching keeps an idle service quiet."
  type        = string
  default     = "notBreaching"

  validation {
    condition     = contains(["notBreaching", "breaching", "ignore", "missing"], var.treat_missing_data)
    error_message = "treat_missing_data must be notBreaching, breaching, ignore or missing."
  }
}

variable "runbook_url" {
  description = "Appended to every alarm description so that a notification links straight to the runbook."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to every alarm."
  type        = map(string)
  default     = {}
}
