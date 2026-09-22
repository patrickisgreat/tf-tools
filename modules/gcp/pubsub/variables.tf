variable "name" {
  description = "Name of the Pub/Sub topic."
  type        = string
}

variable "project" {
  description = "GCP project ID. Defaults to the provider's project when null."
  type        = string
  default     = null
}

variable "message_retention_duration" {
  description = "How long the topic retains unacknowledged messages (e.g. \"86400s\"). Null leaves it unset."
  type        = string
  default     = null
}

variable "kms_key_name" {
  description = "Optional CMEK key for topic message encryption (projects/.../cryptoKeys/...)."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the topic and subscriptions."
  type        = map(string)
  default     = {}
}

variable "subscriptions" {
  description = "Subscriptions to create on the topic."
  type = list(object({
    name                       = string
    ack_deadline_seconds       = optional(number, 10)
    message_retention_duration = optional(string, "604800s")
    retain_acked_messages      = optional(bool, false)
    enable_message_ordering    = optional(bool, false)
    filter                     = optional(string)
    expiration_ttl             = optional(string) # e.g. "2678400s"; null = never expire
    push_endpoint              = optional(string) # null = pull subscription
    dead_letter_topic          = optional(string)
    max_delivery_attempts      = optional(number, 5)
    subscribers                = optional(list(string), []) # granted roles/pubsub.subscriber on this subscription
  }))
  default = []

  validation {
    condition = alltrue(flatten([
      for s in var.subscriptions : [
        for m in s.subscribers : can(regex("^(user|serviceAccount|group|domain|principal|principalSet):", m))
      ]
    ]))
    error_message = "Each subscriber must be an IAM member string such as \"serviceAccount:x@p.iam.gserviceaccount.com\". allUsers and allAuthenticatedUsers are not accepted."
  }
}

variable "publishers" {
  description = "IAM members granted roles/pubsub.publisher on the topic, e.g. [\"serviceAccount:gmail-api-push@system.gserviceaccount.com\"]. Additive (iam_member), so grants made elsewhere are left alone."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for m in var.publishers : can(regex("^(user|serviceAccount|group|domain|principal|principalSet):", m))])
    error_message = "Each publisher must be an IAM member string such as \"serviceAccount:x@p.iam.gserviceaccount.com\". allUsers and allAuthenticatedUsers are not accepted."
  }
}
