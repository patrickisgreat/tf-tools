# `aws/ecs-autoscaling`

Target-tracking autoscaling for an ECS service. Holds the service at a CPU target by
default, with memory and ALB request-count targets available as additional signals. Each
enabled metric becomes its own policy; Application Auto Scaling scales out on whichever
fires first and scales in only when every policy agrees.

Pair it with `aws/ecs-service`. Because the service's `desired_count` becomes a moving
value once this module owns it, set the service's `desired_count` to the same value as
`min_capacity` so that a re-apply of the service does not snap the count back.

## Usage

```hcl
module "api_scaling" {
  source = "../../modules/aws/ecs-autoscaling"

  cluster_name = module.cluster.name
  service_name = module.api.service_name

  min_capacity = 2
  max_capacity = 20

  cpu_target_percent  = 50
  requests_per_target = 500
  alb_arn_suffix          = module.alb.arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
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
| [aws_appautoscaling_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alb_arn_suffix"></a> [alb\_arn\_suffix](#input\_alb\_arn\_suffix) | arn\_suffix of the application load balancer in front of the service. Only used with requests\_per\_target. | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster the service runs in. | `string` | n/a | yes |
| <a name="input_cpu_target_percent"></a> [cpu\_target\_percent](#input\_cpu\_target\_percent) | Average CPU utilisation to hold the service at. null disables the CPU policy. | `number` | `50` | no |
| <a name="input_disable_scale_in"></a> [disable\_scale\_in](#input\_disable\_scale\_in) | Only ever scale out. Useful during a migration, or for a worker whose backlog must drain. | `bool` | `false` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Upper bound on running tasks. Must be at least min\_capacity. | `number` | `4` | no |
| <a name="input_memory_target_percent"></a> [memory\_target\_percent](#input\_memory\_target\_percent) | Average memory utilisation to hold the service at. null disables the memory policy. | `number` | `null` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | Lower bound on running tasks. The autoscaler never scales in below this. | `number` | `1` | no |
| <a name="input_requests_per_target"></a> [requests\_per\_target](#input\_requests\_per\_target) | ALB requests per task per minute to hold the service at. Needs alb\_arn\_suffix and target\_group\_arn\_suffix. null disables the request-count policy. | `number` | `null` | no |
| <a name="input_scale_in_cooldown"></a> [scale\_in\_cooldown](#input\_scale\_in\_cooldown) | Seconds to wait after a scale-in before another scale-in can start. Longer than scale-out so that bursts are not followed by a premature scale-in. | `number` | `300` | no |
| <a name="input_scale_out_cooldown"></a> [scale\_out\_cooldown](#input\_scale\_out\_cooldown) | Seconds to wait after a scale-out before another scale-out can start. | `number` | `60` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the ECS service to scale. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the scaling target. | `map(string)` | `{}` | no |
| <a name="input_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#input\_target\_group\_arn\_suffix) | arn\_suffix of the target group the service registers with. Only used with requests\_per\_target. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_policy_arns"></a> [policy\_arns](#output\_policy\_arns) | Map of metric key (cpu, memory, requests) to the ARN of its target-tracking policy. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | Application Auto Scaling resource id of the service (service/<cluster>/<service>). |
<!-- END_TF_DOCS -->
