output "arn" {
  description = "ARN of the load balancer."
  value       = aws_lb.this.arn
}

output "arn_suffix" {
  description = "ARN suffix of the load balancer, the LoadBalancer dimension of its CloudWatch metrics."
  value       = aws_lb.this.arn_suffix
}

output "dns_name" {
  description = "Hostname of the load balancer."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Route 53 hosted zone id of the load balancer, for alias records."
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "Security group of the load balancer. Allow this as the source on the targets' security group."
  value       = aws_security_group.this.id
}

output "target_group_arn" {
  description = "ARN of the target group. Pass this to aws/ecs-service as target_group_arn."
  value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group, the TargetGroup dimension of its CloudWatch metrics."
  value       = aws_lb_target_group.this.arn_suffix
}

output "http_listener_arn" {
  description = "ARN of the port 80 listener."
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the port 443 listener, or null when no certificate was supplied."
  value       = one(aws_lb_listener.https[*].arn)
}
