# Inputs. Every variable needs a description and type. Required inputs have no
# default; optional inputs always do. Add validation where it's cheap.

variable "name" {
  description = "Name of the primary resource this module manages."
  type        = string
}

variable "tags" {
  description = "Tags/labels to apply to created resources."
  type        = map(string)
  default     = {}
}
