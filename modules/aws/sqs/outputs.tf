output "id" {
  description = "Queue URL (the resource id)."
  value       = aws_sqs_queue.this.id
}

output "url" {
  description = "Queue URL."
  value       = aws_sqs_queue.this.url
}

output "arn" {
  description = "Queue ARN."
  value       = aws_sqs_queue.this.arn
}

output "name" {
  description = "Queue name."
  value       = aws_sqs_queue.this.name
}
