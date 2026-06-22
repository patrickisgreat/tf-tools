output "arn" {
  description = "ARN of the topic."
  value       = aws_sns_topic.this.arn
}

output "id" {
  description = "ID (ARN) of the topic."
  value       = aws_sns_topic.this.id
}

output "name" {
  description = "Name of the topic."
  value       = aws_sns_topic.this.name
}

output "subscription_arns" {
  description = "Map of subscription key to subscription ARN."
  value       = { for k, s in aws_sns_topic_subscription.this : k => s.arn }
}
