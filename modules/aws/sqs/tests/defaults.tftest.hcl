# `terraform test` suite for aws/sqs. Runs against a mocked AWS provider, so it
# needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "aws" {}

variables {
  name = "tf-tools-test-queue"
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = aws_sqs_queue.this.sqs_managed_sse_enabled
    error_message = "Queues must be encrypted at rest by default (SSE-SQS) when no KMS key is supplied."
  }

  assert {
    condition     = aws_sqs_queue.this.fifo_queue == false
    error_message = "Standard queues are the default; FIFO must be opt-in."
  }

  assert {
    condition     = aws_sqs_queue.this.visibility_timeout_seconds == 30
    error_message = "visibility_timeout_seconds should default to the SQS default of 30."
  }

  # `redrive_policy` is not asserted to be absent here: the provider marks it
  # Optional+Computed, so it reads as unknown at plan time. See the "known
  # limits" section of docs/TESTING.md.
}

run "kms_encryption_plans_cleanly" {
  command = plan

  variables {
    kms_master_key_id = "alias/aws/sqs"
  }

  # This run block is primarily a regression guard for the ConflictsWith bug:
  # `sqs_managed_sse_enabled` and `kms_master_key_id` conflict in the provider,
  # and that check fires on an argument being *present* in config, so setting
  # the former to `false` alongside a key still errored. Only `null` omits it.
  # The plan reaching the assertions at all is the real assertion here — before
  # the fix, this run failed with "Conflicting configuration arguments".

  assert {
    condition     = aws_sqs_queue.this.kms_master_key_id == "alias/aws/sqs"
    error_message = "A supplied KMS key must be wired to the queue."
  }

  assert {
    condition     = aws_sqs_queue.this.kms_data_key_reuse_period_seconds == 300
    error_message = "The data key reuse period must apply when SSE-KMS is in use."
  }
}

run "dead_letter_target_builds_a_redrive_policy" {
  command = plan

  variables {
    dead_letter_target_arn = "arn:aws:sqs:us-east-1:111122223333:dlq"
    max_receive_count      = 3
  }

  assert {
    condition     = jsondecode(aws_sqs_queue.this.redrive_policy).deadLetterTargetArn == "arn:aws:sqs:us-east-1:111122223333:dlq"
    error_message = "The dead-letter target must appear in the synthesized redrive policy."
  }

  assert {
    condition     = jsondecode(aws_sqs_queue.this.redrive_policy).maxReceiveCount == 3
    error_message = "max_receive_count must appear in the synthesized redrive policy."
  }
}

run "fifo_queue_wiring" {
  command = plan

  variables {
    name                        = "tf-tools-test-queue.fifo"
    fifo_queue                  = true
    content_based_deduplication = true
  }

  assert {
    condition     = aws_sqs_queue.this.fifo_queue
    error_message = "fifo_queue=true must create a FIFO queue."
  }

  assert {
    condition     = aws_sqs_queue.this.content_based_deduplication
    error_message = "content_based_deduplication must apply on a FIFO queue."
  }
}

# The mirror-image cases — `content_based_deduplication` and
# `kms_data_key_reuse_period_seconds` being dropped to null on a standard queue
# / a queue without a KMS key — cannot be asserted at plan time. Both are
# Optional+Computed, so the provider reports them as unknown rather than null.
# Catching those regressions needs a real apply; see docs/TESTING.md.

# --- input validation -------------------------------------------------------

run "rejects_fifo_queue_without_fifo_suffix" {
  command = plan
  variables {
    name       = "tf-tools-test-queue"
    fifo_queue = true
  }
  # The cross-variable check lives on var.fifo_queue, so that is the checkable
  # object the failure is attributed to — not var.name.
  expect_failures = [var.fifo_queue]
}
