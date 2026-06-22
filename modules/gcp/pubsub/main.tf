resource "google_pubsub_topic" "this" {
  name                       = var.name
  project                    = var.project
  labels                     = var.labels
  message_retention_duration = var.message_retention_duration
  kms_key_name               = var.kms_key_name
}

resource "google_pubsub_subscription" "this" {
  for_each = { for s in var.subscriptions : s.name => s }

  name    = each.value.name
  topic   = google_pubsub_topic.this.id
  project = var.project
  labels  = var.labels

  ack_deadline_seconds       = each.value.ack_deadline_seconds
  message_retention_duration = each.value.message_retention_duration
  retain_acked_messages      = each.value.retain_acked_messages
  enable_message_ordering    = each.value.enable_message_ordering
  filter                     = each.value.filter

  dynamic "expiration_policy" {
    for_each = each.value.expiration_ttl != null ? [each.value.expiration_ttl] : []
    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "push_config" {
    for_each = each.value.push_endpoint != null ? [each.value.push_endpoint] : []
    content {
      push_endpoint = push_config.value
    }
  }

  dynamic "dead_letter_policy" {
    for_each = each.value.dead_letter_topic != null ? [1] : []
    content {
      dead_letter_topic     = each.value.dead_letter_topic
      max_delivery_attempts = each.value.max_delivery_attempts
    }
  }
}
