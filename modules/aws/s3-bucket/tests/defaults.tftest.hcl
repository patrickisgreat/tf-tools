# `terraform test` suite for aws/s3-bucket. Runs against a mocked AWS provider,
# so it needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "aws" {}

variables {
  bucket = "tf-tools-test-bucket"
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = length(aws_s3_bucket_public_access_block.this) == 1
    error_message = "Public access must be blocked by default."
  }

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.this[0].block_public_acls,
      aws_s3_bucket_public_access_block.this[0].block_public_policy,
      aws_s3_bucket_public_access_block.this[0].ignore_public_acls,
      aws_s3_bucket_public_access_block.this[0].restrict_public_buckets,
    ])
    error_message = "All four public access block settings must be on — a partial block still leaves an exposure path."
  }

  assert {
    condition     = one(aws_s3_bucket_versioning.this.versioning_configuration).status == "Enabled"
    error_message = "Versioning must be enabled by default so an overwrite or delete is recoverable."
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule).apply_server_side_encryption_by_default).sse_algorithm == "AES256"
    error_message = "Buckets must be encrypted at rest by default."
  }

  assert {
    condition     = one(aws_s3_bucket_ownership_controls.this.rule).object_ownership == "BucketOwnerEnforced"
    error_message = "ACLs must be disabled by default (BucketOwnerEnforced) — ACL-based access is the classic S3 exposure."
  }

  assert {
    condition     = aws_s3_bucket.this.force_destroy == false
    error_message = "force_destroy must default to false so a terraform destroy cannot silently discard objects."
  }
}

run "optional_resources_are_opt_in" {
  command = plan

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 0
    error_message = "No lifecycle configuration should exist until lifecycle_rules are supplied."
  }

  assert {
    condition     = length(aws_s3_bucket_policy.this) == 0
    error_message = "No bucket policy should be attached unless one is supplied."
  }
}

run "kms_encryption_wires_the_key" {
  command = plan

  variables {
    sse_algorithm = "aws:kms"
    kms_key_arn   = "arn:aws:kms:us-east-1:111122223333:key/abc"
  }

  assert {
    condition     = one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule).apply_server_side_encryption_by_default).kms_master_key_id == "arn:aws:kms:us-east-1:111122223333:key/abc"
    error_message = "A supplied kms_key_arn must be used when sse_algorithm is aws:kms."
  }

  assert {
    condition     = one(aws_s3_bucket_server_side_encryption_configuration.this.rule).bucket_key_enabled
    error_message = "bucket_key_enabled must default to true — it cuts KMS request cost substantially."
  }
}

run "lifecycle_rules_render" {
  command = plan

  variables {
    lifecycle_rules = [{
      id                                 = "expire-logs"
      enabled                            = true
      prefix                             = "logs/"
      expiration_days                    = 90
      noncurrent_version_expiration_days = 30
      transitions                        = [{ days = 30, storage_class = "STANDARD_IA" }]
    }]
  }

  assert {
    condition     = length(aws_s3_bucket_lifecycle_configuration.this) == 1
    error_message = "Supplying lifecycle_rules must create a lifecycle configuration."
  }

  assert {
    condition     = one(aws_s3_bucket_lifecycle_configuration.this[0].rule).status == "Enabled"
    error_message = "An enabled=true rule must render as status Enabled."
  }

  assert {
    condition     = one(one(aws_s3_bucket_lifecycle_configuration.this[0].rule).expiration).days == 90
    error_message = "expiration_days must be passed through to the rule."
  }

  assert {
    condition     = one(one(aws_s3_bucket_lifecycle_configuration.this[0].rule).transition).storage_class == "STANDARD_IA"
    error_message = "Transitions must be passed through to the rule."
  }
}

run "policy_attaches_when_supplied" {
  command = plan

  variables {
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }

  assert {
    condition     = length(aws_s3_bucket_policy.this) == 1
    error_message = "A supplied policy must be attached."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_unknown_sse_algorithm" {
  command = plan
  variables { sse_algorithm = "rot13" }
  expect_failures = [var.sse_algorithm]
}

run "rejects_unknown_object_ownership" {
  command = plan
  variables { object_ownership = "Whoever" }
  expect_failures = [var.object_ownership]
}
