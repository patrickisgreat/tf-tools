# `gcp/pubsub`

A Pub/Sub topic with any number of subscriptions (pull or push), including filters,
ordering, expiration, and dead-letter policies.

## Usage

```hcl
module "events" {
  source = "../../modules/gcp/pubsub"

  name = "order-events"

  subscriptions = [
    {
      name                 = "order-events-worker"
      ack_deadline_seconds = 30
    },
    {
      name          = "order-events-webhook"
      push_endpoint = "https://example.com/_pubsub"
      filter        = "attributes.event_type = \"created\""
    },
  ]

  labels = { team = "platform" }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Topic name. | `string` | n/a | yes |
| `project` | GCP project (defaults to provider). | `string` | `null` | no |
| `message_retention_duration` | Topic retention (e.g. `"86400s"`). | `string` | `null` | no |
| `kms_key_name` | CMEK key for the topic. | `string` | `null` | no |
| `labels` | Labels for topic + subscriptions. | `map(string)` | `{}` | no |
| `subscriptions` | List of subscription objects. | `list(object)` | `[]` | no |

Each subscription object: `name`, `ack_deadline_seconds` (10), `message_retention_duration`
(`"604800s"`), `retain_acked_messages` (false), `enable_message_ordering` (false), `filter`,
`expiration_ttl`, `push_endpoint`, `dead_letter_topic`, `max_delivery_attempts` (5).

### Outputs

| Name | Description |
|------|-------------|
| `topic_id` | Fully-qualified topic id. |
| `topic_name` | Topic name. |
| `subscription_ids` | Map of subscription name → id. |
<!-- END_TF_DOCS -->
