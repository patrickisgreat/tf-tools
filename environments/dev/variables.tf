variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix applied to resource names in this environment."
  type        = string
  default     = "dev"
}

variable "default_tags" {
  description = "Extra default tags merged into every resource."
  type        = map(string)
  default     = {}
}
