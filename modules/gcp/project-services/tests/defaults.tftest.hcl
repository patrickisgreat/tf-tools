# `terraform test` suite for gcp/project-services. Runs against a mocked Google
# provider, so it needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "google" {}

variables {
  services = ["gmail.googleapis.com"]
}

run "safe_destroy_defaults" {
  command = plan

  assert {
    condition     = google_project_service.this["gmail.googleapis.com"].disable_on_destroy == false
    error_message = "disable_on_destroy must default to false — a destroy here would disable the API for every other workload in the project."
  }

  assert {
    condition     = google_project_service.this["gmail.googleapis.com"].disable_dependent_services == false
    error_message = "disable_dependent_services must default to false so a destroy cannot cascade across the project."
  }
}

run "enables_one_resource_per_service" {
  command = plan

  variables {
    services = ["gmail.googleapis.com", "pubsub.googleapis.com", "iam.googleapis.com"]
  }

  assert {
    condition     = length(google_project_service.this) == 3
    error_message = "Each requested service must get its own google_project_service resource."
  }

  assert {
    condition     = google_project_service.this["pubsub.googleapis.com"].service == "pubsub.googleapis.com"
    error_message = "Services must be keyed by hostname so adding or removing one does not re-index the others."
  }
}

run "project_is_passed_through" {
  command = plan

  variables {
    project = "example-project"
  }

  assert {
    condition     = google_project_service.this["gmail.googleapis.com"].project == "example-project"
    error_message = "An explicit project must be wired into the resource rather than falling back to the provider."
  }
}

run "destroy_toggles_are_opt_in" {
  command = plan

  variables {
    disable_on_destroy         = true
    disable_dependent_services = true
  }

  assert {
    condition     = google_project_service.this["gmail.googleapis.com"].disable_on_destroy
    error_message = "disable_on_destroy=true must be honoured when a caller opts in."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_empty_service_list" {
  command = plan
  variables { services = [] }
  expect_failures = [var.services]
}

run "rejects_non_googleapis_hostname" {
  command = plan
  variables { services = ["gmail.google.com"] }
  expect_failures = [var.services]
}

run "rejects_bare_service_name" {
  command = plan
  variables { services = ["gmail"] }
  expect_failures = [var.services]
}
