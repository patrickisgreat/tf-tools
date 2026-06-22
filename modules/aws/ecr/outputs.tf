output "repository_url" {
  description = "Repository URL (<registry>/<name>) for docker push/pull."
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN of the repository."
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "Name of the repository."
  value       = aws_ecr_repository.this.name
}

output "registry_id" {
  description = "Registry ID (AWS account ID) hosting the repository."
  value       = aws_ecr_repository.this.registry_id
}
