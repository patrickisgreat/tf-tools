variable "name" {
  description = "Name of the load balancer and its target group (at most 32 characters, ALB naming rules)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,30}[a-zA-Z0-9])?$", var.name))
    error_message = "name must be 1-32 alphanumeric characters or hyphens, and must not start or end with a hyphen (ALB naming rules)."
  }
}

variable "vpc_id" {
  description = "VPC to create the load balancer, target group and security group in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the load balancer nodes, in at least two availability zones. Public subnets for an internet-facing balancer."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "An application load balancer needs subnets in at least two availability zones."
  }
}

variable "internal" {
  description = "Keep the load balancer reachable only from inside the VPC."
  type        = bool
  default     = false
}

variable "ingress_cidr_blocks" {
  description = "CIDR ranges allowed to reach the listeners."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "certificate_arn" {
  description = "ACM certificate for an HTTPS listener on 443. When set, port 80 redirects to 443; when null, port 80 forwards to the target group."
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "TLS negotiation policy for the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "target_port" {
  description = "Port the targets listen on."
  type        = number
  default     = 8080
}

variable "target_protocol_version" {
  description = "Protocol used to talk to the targets: HTTP1, HTTP2 or GRPC."
  type        = string
  default     = "HTTP1"

  validation {
    condition     = contains(["HTTP1", "HTTP2", "GRPC"], var.target_protocol_version)
    error_message = "target_protocol_version must be HTTP1, HTTP2 or GRPC."
  }
}

variable "health_check" {
  description = "Target group health check. matcher is an HTTP status range for HTTP targets or a gRPC status range for GRPC targets."
  type = object({
    path                = optional(string, "/health")
    interval            = optional(number, 15)
    timeout             = optional(number, 5)
    healthy_threshold   = optional(number, 3)
    unhealthy_threshold = optional(number, 2)
    matcher             = optional(string, "200")
  })
  default = {}
}

variable "deregistration_delay" {
  description = "Seconds to drain in-flight requests from a target before it is removed."
  type        = number
  default     = 30
}

variable "idle_timeout" {
  description = "Seconds a connection may be idle before the load balancer closes it."
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "Refuse to delete the load balancer through the API. Turn on for production once the environment is stable."
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket to write access logs to. null disables access logging."
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "Key prefix for access logs within access_logs_bucket."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to every resource."
  type        = map(string)
  default     = {}
}
