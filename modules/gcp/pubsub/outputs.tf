output "topic_id" {
  description = "Fully-qualified topic id (projects/<project>/topics/<name>)."
  value       = google_pubsub_topic.this.id
}

output "topic_name" {
  description = "Topic name."
  value       = google_pubsub_topic.this.name
}

output "subscription_ids" {
  description = "Map of subscription name to fully-qualified subscription id."
  value       = { for k, s in google_pubsub_subscription.this : k => s.id }
}
