# `aws/sns`

An SNS topic with server-side encryption on by default, optional FIFO, an access/delivery
policy escape hatch, and inline subscriptions.

## Usage

```hcl
module "events" {
  source = "../../modules/aws/sns"

  name = "order-events"

  subscriptions = [
    {
      protocol             = "sqs"
      endpoint             = module.orders_queue.arn
      raw_message_delivery = true
    },
    {
      protocol      = "lambda"
      endpoint      = aws_lambda_function.processor.arn
      filter_policy = jsonencode({ event_type = ["created", "updated"] })
    },
  ]

  tags = { Team = "platform" }
}
```

FIFO topic:

```hcl
module "fifo" {
  source                      = "../../modules/aws/sns"
  name                        = "payments.fifo"
  fifo_topic                  = true
  content_based_deduplication = true
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Topic name (FIFO must end in `.fifo`). | `string` | n/a | yes |
| `display_name` | Display name (From for SMS/email). | `string` | `null` | no |
| `fifo_topic` | Create a FIFO topic. | `bool` | `false` | no |
| `content_based_deduplication` | Content-based dedup (FIFO only). | `bool` | `false` | no |
| `kms_master_key_id` | KMS key for SSE (`null` disables). | `string` | `"alias/aws/sns"` | no |
| `delivery_policy` | Delivery policy JSON. | `string` | `null` | no |
| `policy` | Topic access policy JSON. | `string` | `null` | no |
| `subscriptions` | List of subscription objects. | `list(object)` | `[]` | no |
| `tags` | Tags to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `arn` | Topic ARN. |
| `id` | Topic ID (ARN). |
| `name` | Topic name. |
| `subscription_arns` | Map of subscription key → ARN. |
<!-- END_TF_DOCS -->
