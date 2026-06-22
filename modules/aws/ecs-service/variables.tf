variable "name" {
  description = "Name of the ECS service."
  type        = string
}

variable "family" {
  description = "Task definition family. Defaults to the service name when null."
  type        = string
  default     = null
}

variable "cluster_arn" {
  description = "ARN (or name) of the ECS cluster to run in."
  type        = string
}

variable "container_definitions" {
  description = "Container definitions as a JSON string (e.g. via jsonencode([...]))."
  type        = string
}

variable "launch_type" {
  description = "Launch type: FARGATE or EC2."
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["FARGATE", "EC2"], var.launch_type)
    error_message = "launch_type must be FARGATE or EC2."
  }
}

variable "cpu" {
  description = "Task-level CPU units (e.g. \"256\", \"512\", \"1024\")."
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Task-level memory in MiB (e.g. \"512\", \"1024\")."
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of task copies to run."
  type        = number
  default     = 1
}

variable "execution_role_arn" {
  description = "Task execution role ARN (pulls images, writes logs)."
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "Task role ARN (permissions for the application)."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets for the awsvpc network interface."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the awsvpc network interface."
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Assign a public IP to tasks (needed for public-subnet Fargate without NAT)."
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "Optional ALB/NLB target group ARN to register tasks with."
  type        = string
  default     = null
}

variable "lb_container_name" {
  description = "Container name to attach to the load balancer (required with target_group_arn)."
  type        = string
  default     = null
}

variable "lb_container_port" {
  description = "Container port to attach to the load balancer (required with target_group_arn)."
  type        = number
  default     = null
}

variable "enable_execute_command" {
  description = "Enable ECS Exec (SSM) for the service."
  type        = bool
  default     = false
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent during deployments."
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Maximum percent during deployments."
  type        = number
  default     = 200
}

variable "tags" {
  description = "Tags to apply to the service and task definition."
  type        = map(string)
  default     = {}
}
