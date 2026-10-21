# `terraform test` suite for aws/ecs-autoscaling. Runs against a mocked AWS
# provider, so it needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "aws" {}

variables {
  cluster_name = "tf-tools-test-cluster"
  service_name = "tf-tools-test-service"
}

run "defaults" {
  command = plan

  assert {
    condition     = aws_appautoscaling_target.this.resource_id == "service/tf-tools-test-cluster/tf-tools-test-service"
    error_message = "The scaling target must address the service as service/<cluster>/<service>; any other shape is silently ignored by Application Auto Scaling."
  }

  assert {
    condition     = keys(aws_appautoscaling_policy.this) == ["cpu"]
    error_message = "Only the CPU policy should exist by default; memory and request-count scaling are opt-in."
  }

  assert {
    condition     = one(aws_appautoscaling_policy.this["cpu"].target_tracking_scaling_policy_configuration).scale_in_cooldown > one(aws_appautoscaling_policy.this["cpu"].target_tracking_scaling_policy_configuration).scale_out_cooldown
    error_message = "Scale-in must cool down longer than scale-out, otherwise a burst is followed by an immediate scale-in and the service oscillates."
  }

  assert {
    condition     = one(aws_appautoscaling_policy.this["cpu"].target_tracking_scaling_policy_configuration).disable_scale_in == false
    error_message = "Scale-in must be enabled by default; a service that only ever grows is a cost bug."
  }
}

run "every_metric_becomes_a_policy" {
  command = plan

  variables {
    memory_target_percent   = 70
    requests_per_target     = 500
    alb_arn_suffix          = "app/example/0123456789abcdef"
    target_group_arn_suffix = "targetgroup/example/0123456789abcdef"
  }

  assert {
    condition     = toset(keys(aws_appautoscaling_policy.this)) == toset(["cpu", "memory", "requests"])
    error_message = "Each enabled metric must get its own target-tracking policy."
  }

  assert {
    condition     = one(one(aws_appautoscaling_policy.this["requests"].target_tracking_scaling_policy_configuration).predefined_metric_specification).resource_label == "app/example/0123456789abcdef/targetgroup/example/0123456789abcdef"
    error_message = "The request-count policy must label the metric with <alb suffix>/<target group suffix>, which is how CloudWatch scopes ALBRequestCountPerTarget."
  }
}

run "cpu_policy_can_be_disabled" {
  command = plan

  variables {
    cpu_target_percent    = null
    memory_target_percent = 70
  }

  assert {
    condition     = keys(aws_appautoscaling_policy.this) == ["memory"]
    error_message = "cpu_target_percent=null must remove the CPU policy rather than fall back to a default."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_max_below_min" {
  command = plan
  variables {
    min_capacity = 5
    max_capacity = 2
  }
  expect_failures = [var.max_capacity]
}

run "rejects_cpu_target_over_100" {
  command = plan
  variables {
    cpu_target_percent = 150
  }
  expect_failures = [var.cpu_target_percent]
}

run "rejects_request_scaling_without_alb_labels" {
  command = plan
  variables {
    requests_per_target = 500
  }
  expect_failures = [var.requests_per_target]
}
