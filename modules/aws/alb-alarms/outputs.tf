output "alarm_arns" {
  description = "Map of alarm key (error_rate, latency, unhealthy_hosts) to ARN, for the alarms that are enabled."
  value = merge(
    { for a in aws_cloudwatch_metric_alarm.error_rate : "error_rate" => a.arn },
    { for a in aws_cloudwatch_metric_alarm.latency : "latency" => a.arn },
    { for a in aws_cloudwatch_metric_alarm.unhealthy_hosts : "unhealthy_hosts" => a.arn },
  )
}
