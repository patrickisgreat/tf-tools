output "arn" {
  description = "ARN of the delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.this.arn
}

output "name" {
  description = "Name of the delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.this.name
}

output "id" {
  description = "ID of the delivery stream."
  value       = aws_kinesis_firehose_delivery_stream.this.id
}
