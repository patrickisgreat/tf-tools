variable "repository_id" {
  description = "The repository id (last segment of the resource name)."
  type        = string
}

variable "location" {
  description = "Location for the repository (region or multi-region, e.g. us, us-central1)."
  type        = string
  default     = "us"
}

variable "format" {
  description = "Artifact format: DOCKER, MAVEN, NPM, PYTHON, APT, YUM, GO, KFP."
  type        = string
  default     = "DOCKER"

  validation {
    condition     = contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "APT", "YUM", "GO", "KFP"], var.format)
    error_message = "format must be one of DOCKER, MAVEN, NPM, PYTHON, APT, YUM, GO, KFP."
  }
}

variable "description" {
  description = "Description of the repository."
  type        = string
  default     = null
}

variable "project" {
  description = "GCP project ID. Defaults to the provider's project when null."
  type        = string
  default     = null
}

variable "mode" {
  description = "Repository mode: STANDARD_REPOSITORY, REMOTE_REPOSITORY, or VIRTUAL_REPOSITORY."
  type        = string
  default     = "STANDARD_REPOSITORY"

  validation {
    condition     = contains(["STANDARD_REPOSITORY", "REMOTE_REPOSITORY", "VIRTUAL_REPOSITORY"], var.mode)
    error_message = "mode must be STANDARD_REPOSITORY, REMOTE_REPOSITORY, or VIRTUAL_REPOSITORY."
  }
}

variable "kms_key_name" {
  description = "Optional CMEK key for repository encryption (projects/.../cryptoKeys/...)."
  type        = string
  default     = null
}

variable "immutable_tags" {
  description = "For DOCKER repositories, make tags immutable. Null leaves the API default."
  type        = bool
  default     = null
}

variable "labels" {
  description = "Labels to apply to the repository."
  type        = map(string)
  default     = {}
}
