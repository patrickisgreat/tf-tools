# `terraform test` suite for aws/alb-alarms. Runs against a mocked AWS provider,
# so it needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "aws" {}

variables {
  name                     = "tf-tools-test"
  load_balancer_arn_suffix = "app/example/0123456789abcdef"
  target_group_arn_suffix  = "targetgroup/example/0123456789abcdef"
  alarm_actions            = ["arn:aws:sns:us-east-1:111122223333:alerts"]
}

run "defaults" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.error_rate) == 1 && length(aws_cloudwatch_metric_alarm.latency) == 1 && length(aws_cloudwatch_metric_alarm.unhealthy_hosts) == 1
    error_message = "All three alarms must exist by default; a service with no alarms fails silently."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.error_rate[0].threshold == 5 && aws_cloudwatch_metric_alarm.error_rate[0].evaluation_periods == 2
    error_message = "The error-rate alarm must default to 5% over two periods."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.latency[0].extended_statistic == "p95"
    error_message = "Latency must be judged on p95 by default; an average hides the tail that users actually feel."
  }

  assert {
    condition     = contains(aws_cloudwatch_metric_alarm.error_rate[0].ok_actions, "arn:aws:sns:us-east-1:111122223333:alerts")
    error_message = "ok_actions must default to alarm_actions so that a recovery is announced on the same channel as the incident."
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.error_rate[0].treat_missing_data == "notBreaching"
    error_message = "Missing data must not breach by default, otherwise an idle environment pages all night."
  }

  assert {
    condition     = alltrue([for q in aws_cloudwatch_metric_alarm.error_rate[0].metric_query : one(q.metric).dimensions.TargetGroup == "targetgroup/example/0123456789abcdef" if q.id != "error_rate"])
    error_message = "Both metrics in the error-rate expression must be scoped to the supplied target group."
  }
}

run "runbook_reaches_every_description" {
  command = plan

  variables {
    runbook_url = "https://example.com/runbook"
  }

  assert {
    condition     = endswith(aws_cloudwatch_metric_alarm.error_rate[0].alarm_description, "Runbook: https://example.com/runbook") && endswith(aws_cloudwatch_metric_alarm.latency[0].alarm_description, "Runbook: https://example.com/runbook") && endswith(aws_cloudwatch_metric_alarm.unhealthy_hosts[0].alarm_description, "Runbook: https://example.com/runbook")
    error_message = "The runbook URL must appear in every alarm description so the notification links to it."
  }
}

run "alarms_can_be_disabled_individually" {
  command = plan

  variables {
    latency_threshold_seconds = null
    unhealthy_host_threshold  = null
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.latency) == 0 && length(aws_cloudwatch_metric_alarm.unhealthy_hosts) == 0 && length(aws_cloudwatch_metric_alarm.error_rate) == 1
    error_message = "A null threshold must remove that alarm and leave the others in place."
  }
}

run "average_latency_uses_statistic_not_extended_statistic" {
  command = plan

  variables {
    latency_statistic = "Average"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.latency[0].statistic == "Average"
    error_message = "Average must be passed as statistic; CloudWatch rejects it as an extended_statistic."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_error_rate_over_100" {
  command = plan
  variables {
    error_rate_threshold_percent = 120
  }
  expect_failures = [var.error_rate_threshold_percent]
}

run "rejects_unknown_statistic" {
  command = plan
  variables {
    latency_statistic = "Maximum"
  }
  expect_failures = [var.latency_statistic]
}

run "rejects_unknown_missing_data_mode" {
  command = plan
  variables {
    treat_missing_data = "alarm"
  }
  expect_failures = [var.treat_missing_data]
}
