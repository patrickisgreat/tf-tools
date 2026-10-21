output "arn" {
  description = "ARN of the cluster. Pass this to aws/ecs-service as cluster_arn."
  value       = aws_ecs_cluster.this.arn
}

output "name" {
  description = "Name of the cluster. aws/ecs-autoscaling needs this to build its resource id."
  value       = aws_ecs_cluster.this.name
}

output "id" {
  description = "ID (ARN) of the cluster."
  value       = aws_ecs_cluster.this.id
}
