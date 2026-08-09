locals {
  redrive_policy = var.dead_letter_target_arn != null ? jsonencode({
    deadLetterTargetArn = var.dead_letter_target_arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  use_kms = var.kms_master_key_id != null
}

resource "aws_sqs_queue" "this" {
  name                        = var.name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null

  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  # SSE-KMS when a key is supplied, otherwise SSE-SQS. The two are ConflictsWith
  # in the provider, and that check fires on an argument being *present* in the
  # config — setting sqs_managed_sse_enabled to false alongside a key is still a
  # conflict. Only null actually omits it.
  sqs_managed_sse_enabled           = local.use_kms ? null : var.sqs_managed_sse_enabled
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = local.use_kms ? var.kms_data_key_reuse_period_seconds : null

  redrive_policy       = local.redrive_policy
  redrive_allow_policy = var.redrive_allow_policy
  policy               = var.policy

  tags = var.tags
}
