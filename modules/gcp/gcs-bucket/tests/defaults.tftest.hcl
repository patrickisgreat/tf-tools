# `terraform test` suite for gcp/gcs-bucket. Runs against a mocked Google
# provider, so it needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "google" {}

variables {
  name = "tf-tools-test-bucket"
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = google_storage_bucket.this.uniform_bucket_level_access
    error_message = "UBLA must be enabled by default — per-object ACLs are the GCS equivalent of the classic S3 exposure."
  }

  assert {
    condition     = google_storage_bucket.this.public_access_prevention == "enforced"
    error_message = "Public access prevention must be enforced by default, not inherited from the org policy."
  }

  assert {
    condition     = google_storage_bucket.this.force_destroy == false
    error_message = "force_destroy must default to false so a terraform destroy cannot silently discard objects."
  }

  assert {
    condition     = google_storage_bucket.this.storage_class == "STANDARD"
    error_message = "storage_class should default to STANDARD."
  }
}

run "optional_blocks_are_opt_in" {
  command = plan

  assert {
    condition     = length(google_storage_bucket.this.encryption) == 0
    error_message = "No CMEK encryption block should be emitted unless kms_key_name is supplied — an empty block breaks the plan."
  }

  assert {
    condition     = length(google_storage_bucket.this.lifecycle_rule) == 0
    error_message = "No lifecycle rules should exist until lifecycle_rules are supplied."
  }
}

run "cmek_wires_the_key" {
  command = plan

  variables {
    kms_key_name = "projects/p/locations/us/keyRings/r/cryptoKeys/k"
  }

  assert {
    condition     = google_storage_bucket.this.encryption[0].default_kms_key_name == "projects/p/locations/us/keyRings/r/cryptoKeys/k"
    error_message = "A supplied kms_key_name must be wired into the encryption block."
  }
}

run "versioning_toggles" {
  command = plan

  variables {
    versioning_enabled = true
  }

  assert {
    condition     = google_storage_bucket.this.versioning[0].enabled
    error_message = "versioning_enabled=true must enable object versioning."
  }
}

run "lifecycle_rules_render" {
  command = plan

  variables {
    lifecycle_rules = [{
      action = { type = "SetStorageClass", storage_class = "NEARLINE" }
      condition = {
        age                   = 30
        created_before        = null
        with_state            = "LIVE"
        matches_storage_class = ["STANDARD"]
        num_newer_versions    = null
      }
    }]
  }

  assert {
    condition     = length(google_storage_bucket.this.lifecycle_rule) == 1
    error_message = "Supplying lifecycle_rules must render a lifecycle_rule block."
  }

  assert {
    condition     = one(google_storage_bucket.this.lifecycle_rule[0].action).storage_class == "NEARLINE"
    error_message = "The rule's target storage class must be passed through."
  }

  assert {
    condition     = one(google_storage_bucket.this.lifecycle_rule[0].condition).age == 30
    error_message = "The rule's age condition must be passed through."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_unknown_storage_class" {
  command = plan
  variables { storage_class = "GLACIER" }
  expect_failures = [var.storage_class]
}

run "rejects_unknown_public_access_prevention" {
  command = plan
  variables { public_access_prevention = "disabled" }
  expect_failures = [var.public_access_prevention]
}
