# `terraform test` suite for aws/ecs-cluster. Runs against a mocked AWS provider,
# so it needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "aws" {}

variables {
  name = "tf-tools-test-cluster"
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = one(aws_ecs_cluster.this.setting).value == "enabled"
    error_message = "Container Insights must be on by default: without it there are no per-service CPU and memory metrics to alarm or autoscale on."
  }

  assert {
    condition     = length(aws_ecs_cluster_capacity_providers.this) == 1
    error_message = "The Fargate capacity providers must be associated by default so that services can use a capacity_provider_strategy without extra wiring."
  }

  assert {
    condition     = contains(aws_ecs_cluster_capacity_providers.this[0].capacity_providers, "FARGATE")
    error_message = "FARGATE must be among the default capacity providers."
  }

  assert {
    condition     = length(aws_ecs_cluster.this.configuration) == 0
    error_message = "No execute-command configuration should be created unless a log group is supplied."
  }
}

run "container_insights_can_be_disabled" {
  command = plan

  variables {
    container_insights = false
  }

  assert {
    condition     = one(aws_ecs_cluster.this.setting).value == "disabled"
    error_message = "container_insights=false must disable the containerInsights setting rather than silently leaving it on."
  }
}

run "no_capacity_providers_means_no_association" {
  command = plan

  variables {
    capacity_providers = []
  }

  assert {
    condition     = length(aws_ecs_cluster_capacity_providers.this) == 0
    error_message = "An empty capacity_providers list must not create an association resource."
  }
}

run "default_strategy_is_wired" {
  command = plan

  variables {
    default_capacity_provider_strategy = [
      { capacity_provider = "FARGATE", weight = 1, base = 1 },
      { capacity_provider = "FARGATE_SPOT", weight = 3 },
    ]
  }

  assert {
    condition     = length(aws_ecs_cluster_capacity_providers.this[0].default_capacity_provider_strategy) == 2
    error_message = "Every entry of default_capacity_provider_strategy must become a strategy block."
  }
}

run "execute_command_logging_is_wired" {
  command = plan

  variables {
    execute_command_log_group_name = "/ecs/exec"
  }

  assert {
    condition     = one(one(one(aws_ecs_cluster.this.configuration).execute_command_configuration).log_configuration).cloud_watch_log_group_name == "/ecs/exec"
    error_message = "A supplied execute-command log group must reach the cluster configuration."
  }

  assert {
    condition     = one(one(one(aws_ecs_cluster.this.configuration).execute_command_configuration).log_configuration).cloud_watch_encryption_enabled
    error_message = "ECS Exec session logs must be encrypted in CloudWatch."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_invalid_name" {
  command = plan
  variables {
    name = "has spaces"
  }
  expect_failures = [var.name]
}

run "rejects_strategy_with_unknown_provider" {
  command = plan
  variables {
    capacity_providers                 = ["FARGATE"]
    default_capacity_provider_strategy = [{ capacity_provider = "FARGATE_SPOT", weight = 1 }]
  }
  expect_failures = [var.default_capacity_provider_strategy]
}
