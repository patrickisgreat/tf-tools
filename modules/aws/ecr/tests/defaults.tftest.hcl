# `terraform test` suite for aws/ecr. Runs against a mocked AWS provider, so it
# needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "aws" {}

variables {
  name = "team/service"
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = aws_ecr_repository.this.image_tag_mutability == "IMMUTABLE"
    error_message = "Image tags must be immutable by default — mutable tags let a pushed digest change under a running deployment."
  }

  assert {
    condition     = aws_ecr_repository.this.image_scanning_configuration[0].scan_on_push
    error_message = "Vulnerability scanning must be enabled by default."
  }

  assert {
    condition     = aws_ecr_repository.this.encryption_configuration[0].encryption_type == "AES256"
    error_message = "Repositories must be encrypted at rest by default."
  }

  assert {
    condition     = aws_ecr_repository.this.force_delete == false
    error_message = "force_delete must default to false so a terraform destroy cannot silently discard images."
  }
}

run "default_lifecycle_policy_is_synthesized" {
  command = plan

  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 1
    error_message = "The default keep_last_n_images / expire_untagged_after_days values should synthesize a lifecycle policy."
  }

  # Both helper rules should be present, and the tagStatus="any" rule must sort
  # last — ECR rejects a policy where it does not carry the highest priority.
  assert {
    condition     = length(jsondecode(aws_ecr_lifecycle_policy.this[0].policy).rules) == 2
    error_message = "Both lifecycle helper rules should be present at default settings."
  }

  assert {
    condition = alltrue([
      for r in jsondecode(aws_ecr_lifecycle_policy.this[0].policy).rules :
      r.selection.tagStatus == "untagged" ? r.rulePriority == 1 : r.rulePriority == 2
    ])
    error_message = "The tagStatus=any rule must have the highest rulePriority or ECR rejects the policy."
  }

  # Regression guard for the bug this module was written around: encoding the
  # rules together injects a null countUnit that ECR's validator rejects.
  assert {
    condition = alltrue([
      for r in jsondecode(aws_ecr_lifecycle_policy.this[0].policy).rules :
      r.selection.countType == "imageCountMoreThan" ? !can(r.selection.countUnit) : true
    ])
    error_message = "An imageCountMoreThan rule must not carry a countUnit key — ECR rejects it."
  }
}

run "lifecycle_helpers_can_be_disabled" {
  command = plan

  variables {
    keep_last_n_images         = 0
    expire_untagged_after_days = 0
  }

  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 0
    error_message = "Disabling both lifecycle helpers should attach no lifecycle policy at all."
  }
}

run "raw_lifecycle_policy_overrides_helpers" {
  command = plan

  variables {
    lifecycle_policy = "{\"rules\": []}"
  }

  assert {
    condition     = aws_ecr_lifecycle_policy.this[0].policy == "{\"rules\": []}"
    error_message = "An explicit lifecycle_policy must override the helper-synthesized policy."
  }
}

run "repository_policy_is_opt_in" {
  command = plan

  assert {
    condition     = length(aws_ecr_repository_policy.this) == 0
    error_message = "No repository policy should be attached unless one is supplied."
  }
}

run "repository_policy_attaches_when_supplied" {
  command = plan

  variables {
    repository_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }

  assert {
    condition     = length(aws_ecr_repository_policy.this) == 1
    error_message = "A supplied repository_policy must be attached."
  }
}

run "kms_key_is_wired_when_encryption_type_is_kms" {
  command = plan

  variables {
    encryption_type = "KMS"
    kms_key         = "arn:aws:kms:us-east-1:111122223333:key/abc"
  }

  assert {
    condition     = aws_ecr_repository.this.encryption_configuration[0].encryption_type == "KMS"
    error_message = "encryption_type must be passed through to the repository."
  }

  assert {
    condition     = aws_ecr_repository.this.encryption_configuration[0].kms_key == "arn:aws:kms:us-east-1:111122223333:key/abc"
    error_message = "A supplied kms_key must be used when encryption_type is KMS."
  }

  # The inverse — kms_key being dropped for AES256 — is not asserted here: the
  # provider marks that attribute Computed, so it is unknown at plan time and no
  # assertion can observe it without a real apply.
}

# --- input validation -------------------------------------------------------

run "rejects_uppercase_name" {
  command = plan
  variables { name = "Team/Service" }
  expect_failures = [var.name]
}

run "rejects_name_with_invalid_characters" {
  command = plan
  variables { name = "team/service!" }
  expect_failures = [var.name]
}

run "rejects_unknown_tag_mutability" {
  command = plan
  variables { image_tag_mutability = "SOMETIMES" }
  expect_failures = [var.image_tag_mutability]
}

run "rejects_unknown_encryption_type" {
  command = plan
  variables { encryption_type = "ROT13" }
  expect_failures = [var.encryption_type]
}

run "rejects_negative_keep_last_n_images" {
  command = plan
  variables { keep_last_n_images = -1 }
  expect_failures = [var.keep_last_n_images]
}

run "rejects_negative_expire_untagged_after_days" {
  command = plan
  variables { expire_untagged_after_days = -1 }
  expect_failures = [var.expire_untagged_after_days]
}
