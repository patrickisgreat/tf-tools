# `terraform test` suite for gcp/pubsub. Runs against a mocked Google provider, so it
# needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "google" {}

variables {
  name = "tf-tools-test-topic"
}

run "no_grants_by_default" {
  command = plan

  assert {
    condition     = length(google_pubsub_topic_iam_member.publisher) == 0
    error_message = "No publisher grants may exist unless publishers are supplied."
  }

  assert {
    condition     = length(google_pubsub_subscription_iam_member.subscriber) == 0
    error_message = "No subscriber grants may exist unless subscribers are supplied."
  }
}

run "subscriptions_default_to_pull" {
  command = plan

  variables {
    subscriptions = [{ name = "worker" }]
  }

  assert {
    condition     = length(google_pubsub_subscription.this["worker"].push_config) == 0
    error_message = "A subscription with no push_endpoint must be a pull subscription."
  }
}

run "publishers_are_granted_on_the_topic" {
  command = plan

  variables {
    publishers = ["serviceAccount:gmail-api-push@system.gserviceaccount.com"]
  }

  assert {
    condition     = google_pubsub_topic_iam_member.publisher["serviceAccount:gmail-api-push@system.gserviceaccount.com"].role == "roles/pubsub.publisher"
    error_message = "Each publisher must get roles/pubsub.publisher on the topic."
  }
}

run "subscribers_are_granted_per_subscription" {
  command = plan

  variables {
    subscriptions = [
      { name = "a", subscribers = ["serviceAccount:worker@p.iam.gserviceaccount.com"] },
      { name = "b" },
    ]
  }

  assert {
    condition     = length(google_pubsub_subscription_iam_member.subscriber) == 1
    error_message = "Only the subscription that lists subscribers may get a grant."
  }

  assert {
    condition     = google_pubsub_subscription_iam_member.subscriber["a|serviceAccount:worker@p.iam.gserviceaccount.com"].role == "roles/pubsub.subscriber"
    error_message = "Each subscriber must get roles/pubsub.subscriber on its own subscription."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_public_publishers" {
  command = plan
  variables { publishers = ["allUsers"] }
  expect_failures = [var.publishers]
}

run "rejects_public_subscribers" {
  command = plan
  variables {
    subscriptions = [{ name = "a", subscribers = ["allAuthenticatedUsers"] }]
  }
  expect_failures = [var.subscriptions]
}
