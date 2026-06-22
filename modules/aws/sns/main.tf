resource "aws_sns_topic" "this" {
  name                        = var.name
  display_name                = var.display_name
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null
  kms_master_key_id           = var.kms_master_key_id
  delivery_policy             = var.delivery_policy
  policy                      = var.policy
  tags                        = var.tags
}

resource "aws_sns_topic_subscription" "this" {
  # Keyed by protocol+endpoint so adding/removing one subscription doesn't churn the others.
  for_each = { for s in var.subscriptions : "${s.protocol}:${s.endpoint}" => s }

  topic_arn            = aws_sns_topic.this.arn
  protocol             = each.value.protocol
  endpoint             = each.value.endpoint
  raw_message_delivery = each.value.raw_message_delivery
  filter_policy        = each.value.filter_policy
  filter_policy_scope  = each.value.filter_policy_scope
}
