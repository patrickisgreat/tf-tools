locals {
  ok_actions = var.ok_actions == null ? var.alarm_actions : var.ok_actions
  runbook    = var.runbook_url == null ? "" : " Runbook: ${var.runbook_url}"

  dimensions = {
    LoadBalancer = var.load_balancer_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "error_rate" {
  count = var.error_rate_threshold_percent == null ? 0 : 1

  alarm_name          = "${var.name}-high-error-rate"
  alarm_description   = "More than ${var.error_rate_threshold_percent}% of requests to ${var.name} returned 5xx for ${var.error_rate_evaluation_periods} periods of ${var.period_seconds}s.${local.runbook}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.error_rate_evaluation_periods
  threshold           = var.error_rate_threshold_percent
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = var.alarm_actions
  ok_actions          = local.ok_actions
  tags                = var.tags

  metric_query {
    id          = "error_rate"
    expression  = "IF(requests > 0, 100 * errors / requests, 0)"
    label       = "5xx percentage"
    return_data = true
  }

  metric_query {
    id = "errors"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "HTTPCode_Target_5XX_Count"
      period      = var.period_seconds
      stat        = "Sum"
      dimensions  = local.dimensions
    }
  }

  metric_query {
    id = "requests"
    metric {
      namespace   = "AWS/ApplicationELB"
      metric_name = "RequestCount"
      period      = var.period_seconds
      stat        = "Sum"
      dimensions  = local.dimensions
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "latency" {
  count = var.latency_threshold_seconds == null ? 0 : 1

  alarm_name          = "${var.name}-high-latency"
  alarm_description   = "${var.latency_statistic} response time of ${var.name} exceeded ${var.latency_threshold_seconds}s for ${var.latency_evaluation_periods} periods of ${var.period_seconds}s.${local.runbook}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.latency_evaluation_periods
  threshold           = var.latency_threshold_seconds
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  period              = var.period_seconds
  statistic           = var.latency_statistic == "Average" ? "Average" : null
  extended_statistic  = var.latency_statistic == "Average" ? null : var.latency_statistic
  dimensions          = local.dimensions
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = var.alarm_actions
  ok_actions          = local.ok_actions
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  count = var.unhealthy_host_threshold == null ? 0 : 1

  alarm_name          = "${var.name}-unhealthy-hosts"
  alarm_description   = "${var.name} has at least ${var.unhealthy_host_threshold} target(s) failing health checks.${local.runbook}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  threshold           = var.unhealthy_host_threshold
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  period              = var.period_seconds
  statistic           = "Maximum"
  dimensions          = local.dimensions
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = var.alarm_actions
  ok_actions          = local.ok_actions
  tags                = var.tags
}
