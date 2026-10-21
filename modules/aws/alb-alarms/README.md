# `aws/alb-alarms`

The three CloudWatch alarms every service behind an application load balancer should
have, wired to whatever actions you pass in (usually an `aws/sns` topic):

| Alarm | Metric | Default |
|-------|--------|---------|
| `<name>-high-error-rate` | Target 5xx as a percentage of requests (metric math) | > 5% for 2 minutes |
| `<name>-high-latency` | `TargetResponseTime` at a percentile | p95 > 3s for 2 minutes |
| `<name>-unhealthy-hosts` | `UnHealthyHostCount` | >= 1 for 2 minutes |

Each alarm can be switched off by setting its threshold to `null`. A `runbook_url` is
appended to every description so that the notification links straight to it.

## Usage

```hcl
module "alerts_topic" {
  source        = "../../modules/aws/sns"
  name          = "orders-prod-alerts"
  subscriptions = [{ protocol = "email", endpoint = "oncall@example.com" }]
}

module "alarms" {
  source = "../../modules/aws/alb-alarms"

  name                     = "orders-prod"
  load_balancer_arn_suffix = module.alb.arn_suffix
  target_group_arn_suffix  = module.alb.target_group_arn_suffix

  alarm_actions = [module.alerts_topic.arn]
  runbook_url   = "https://wiki.example.com/runbooks/orders"

  latency_threshold_seconds = 1.5
  latency_statistic         = "p99"
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.40 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.69.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_metric_alarm.error_rate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unhealthy_hosts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | ARNs notified when an alarm enters ALARM, usually an SNS topic from aws/sns. | `list(string)` | `[]` | no |
| <a name="input_error_rate_evaluation_periods"></a> [error\_rate\_evaluation\_periods](#input\_error\_rate\_evaluation\_periods) | Consecutive periods the error rate must breach before alarming. | `number` | `2` | no |
| <a name="input_error_rate_threshold_percent"></a> [error\_rate\_threshold\_percent](#input\_error\_rate\_threshold\_percent) | Percentage of requests answered with HTTP 5xx by the targets that triggers the error-rate alarm. null disables it. | `number` | `5` | no |
| <a name="input_latency_evaluation_periods"></a> [latency\_evaluation\_periods](#input\_latency\_evaluation\_periods) | Consecutive periods the latency must breach before alarming. | `number` | `2` | no |
| <a name="input_latency_statistic"></a> [latency\_statistic](#input\_latency\_statistic) | Statistic of TargetResponseTime to compare: a percentile such as p95 or p99, or Average. | `string` | `"p95"` | no |
| <a name="input_latency_threshold_seconds"></a> [latency\_threshold\_seconds](#input\_latency\_threshold\_seconds) | Target response time that triggers the latency alarm. null disables it. | `number` | `3` | no |
| <a name="input_load_balancer_arn_suffix"></a> [load\_balancer\_arn\_suffix](#input\_load\_balancer\_arn\_suffix) | arn\_suffix of the application load balancer (the LoadBalancer metric dimension). | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Prefix for the alarm names, typically <service>-<environment>. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | ARNs notified when an alarm returns to OK. Defaults to alarm\_actions so that recoveries are announced too. | `list(string)` | `null` | no |
| <a name="input_period_seconds"></a> [period\_seconds](#input\_period\_seconds) | Length of each evaluation period. | `number` | `60` | no |
| <a name="input_runbook_url"></a> [runbook\_url](#input\_runbook\_url) | Appended to every alarm description so that a notification links straight to the runbook. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to every alarm. | `map(string)` | `{}` | no |
| <a name="input_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#input\_target\_group\_arn\_suffix) | arn\_suffix of the target group (the TargetGroup metric dimension). | `string` | n/a | yes |
| <a name="input_treat_missing_data"></a> [treat\_missing\_data](#input\_treat\_missing\_data) | How to treat periods with no data: notBreaching, breaching, ignore or missing. notBreaching keeps an idle service quiet. | `string` | `"notBreaching"` | no |
| <a name="input_unhealthy_host_threshold"></a> [unhealthy\_host\_threshold](#input\_unhealthy\_host\_threshold) | Number of unhealthy targets at which the unhealthy-hosts alarm fires. null disables it. | `number` | `1` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alarm_arns"></a> [alarm\_arns](#output\_alarm\_arns) | Map of alarm key (error\_rate, latency, unhealthy\_hosts) to ARN, for the alarms that are enabled. |
<!-- END_TF_DOCS -->
