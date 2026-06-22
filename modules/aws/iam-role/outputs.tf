output "arn" {
  description = "ARN of the role."
  value       = aws_iam_role.this.arn
}

output "name" {
  description = "Name of the role."
  value       = aws_iam_role.this.name
}

output "id" {
  description = "ID (name) of the role."
  value       = aws_iam_role.this.id
}

output "unique_id" {
  description = "Stable, unique string identifying the role."
  value       = aws_iam_role.this.unique_id
}
