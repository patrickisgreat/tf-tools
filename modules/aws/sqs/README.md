# `aws/sqs`

An SQS queue with encryption on by default (SSE-SQS), optional FIFO, optional dead-letter
redrive, and policy escape hatches.

## Usage

Standard queue with a dead-letter queue:

```hcl
module "dlq" {
  source                    = "../../modules/aws/sqs"
  name                      = "orders-dlq"
  message_retention_seconds = 1209600
}

module "orders" {
  source                     = "../../modules/aws/sqs"
  name                       = "orders"
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 20 # long polling

  dead_letter_target_arn = module.dlq.arn
  max_receive_count      = 5

  tags = { Team = "platform" }
}
```

FIFO queue with SSE-KMS:

```hcl
module "payments" {
  source                      = "../../modules/aws/sqs"
  name                        = "payments.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  kms_master_key_id           = "alias/aws/sqs"
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Queue name (FIFO must end in `.fifo`). | `string` | n/a | yes |
| `fifo_queue` | Create a FIFO queue. | `bool` | `false` | no |
| `content_based_deduplication` | Content-based dedup (FIFO only). | `bool` | `false` | no |
| `visibility_timeout_seconds` | Visibility timeout. | `number` | `30` | no |
| `message_retention_seconds` | Retention period. | `number` | `345600` | no |
| `max_message_size` | Max message bytes. | `number` | `262144` | no |
| `delay_seconds` | Delivery delay. | `number` | `0` | no |
| `receive_wait_time_seconds` | Long-poll wait. | `number` | `0` | no |
| `sqs_managed_sse_enabled` | Enable SSE-SQS. | `bool` | `true` | no |
| `kms_master_key_id` | SSE-KMS key (takes precedence). | `string` | `null` | no |
| `kms_data_key_reuse_period_seconds` | KMS data key reuse window. | `number` | `300` | no |
| `dead_letter_target_arn` | DLQ ARN (enables redrive). | `string` | `null` | no |
| `max_receive_count` | Receives before DLQ. | `number` | `5` | no |
| `redrive_allow_policy` | Redrive allow policy JSON. | `string` | `null` | no |
| `policy` | Queue access policy JSON. | `string` | `null` | no |
| `tags` | Tags to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `id` | Queue URL (resource id). |
| `url` | Queue URL. |
| `arn` | Queue ARN. |
| `name` | Queue name. |
<!-- END_TF_DOCS -->
