output "resource_id" {
  description = "Application Auto Scaling resource id of the service (service/<cluster>/<service>)."
  value       = aws_appautoscaling_target.this.resource_id
}

output "policy_arns" {
  description = "Map of metric key (cpu, memory, requests) to the ARN of its target-tracking policy."
  value       = { for k, p in aws_appautoscaling_policy.this : k => p.arn }
}
