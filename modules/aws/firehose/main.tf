resource "aws_kinesis_firehose_delivery_stream" "this" {
  name        = var.name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = var.role_arn
    bucket_arn          = var.bucket_arn
    buffering_size      = var.buffering_size
    buffering_interval  = var.buffering_interval
    compression_format  = var.compression_format
    prefix              = var.prefix
    error_output_prefix = var.error_output_prefix

    dynamic "cloudwatch_logging_options" {
      for_each = var.cloudwatch_logging_enabled ? [1] : []
      content {
        enabled         = true
        log_group_name  = var.cloudwatch_log_group_name
        log_stream_name = var.cloudwatch_log_stream_name
      }
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.server_side_encryption_enabled ? [1] : []
    content {
      enabled  = true
      key_type = var.sse_key_type
      key_arn  = var.sse_key_type == "CUSTOMER_MANAGED_CMK" ? var.sse_key_arn : null
    }
  }

  tags = var.tags
}
