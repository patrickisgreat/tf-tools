# `aws/firehose`

A Kinesis Data Firehose delivery stream that writes to S3 (`extended_s3`), with buffering,
compression, optional CloudWatch error logging, and optional server-side encryption.

You bring the destination bucket and the Firehose IAM role (see `aws/s3-bucket` and
`aws/iam-role`); this module wires up the stream.

## Usage

```hcl
module "events_firehose" {
  source = "../../modules/aws/firehose"

  name       = "events-to-s3"
  role_arn   = module.firehose_role.arn
  bucket_arn = module.events_bucket.arn

  buffering_size      = 64
  buffering_interval  = 300
  compression_format  = "GZIP"
  prefix              = "events/year=!{timestamp:yyyy}/month=!{timestamp:MM}/"
  error_output_prefix = "errors/"

  cloudwatch_logging_enabled = true
  cloudwatch_log_group_name  = "/aws/kinesisfirehose/events"
  cloudwatch_log_stream_name = "s3-delivery"

  tags = { Team = "data" }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Delivery stream name. | `string` | n/a | yes |
| `role_arn` | Firehose IAM role ARN. | `string` | n/a | yes |
| `bucket_arn` | Destination S3 bucket ARN. | `string` | n/a | yes |
| `buffering_size` | Buffer size MB. | `number` | `5` | no |
| `buffering_interval` | Buffer interval seconds. | `number` | `300` | no |
| `compression_format` | Compression for delivered objects. | `string` | `"GZIP"` | no |
| `prefix` | S3 prefix for delivered objects. | `string` | `null` | no |
| `error_output_prefix` | S3 prefix for failed records. | `string` | `null` | no |
| `cloudwatch_logging_enabled` | Enable CloudWatch error logging. | `bool` | `false` | no |
| `cloudwatch_log_group_name` | Log group name. | `string` | `null` | no |
| `cloudwatch_log_stream_name` | Log stream name. | `string` | `null` | no |
| `server_side_encryption_enabled` | Enable stream SSE. | `bool` | `false` | no |
| `sse_key_type` | `AWS_OWNED_CMK` or `CUSTOMER_MANAGED_CMK`. | `string` | `"AWS_OWNED_CMK"` | no |
| `sse_key_arn` | KMS key ARN for customer CMK. | `string` | `null` | no |
| `tags` | Tags to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `arn` | Delivery stream ARN. |
| `name` | Delivery stream name. |
| `id` | Delivery stream id. |
<!-- END_TF_DOCS -->
