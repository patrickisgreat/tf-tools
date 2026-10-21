# `aws/ecs-cluster`

An ECS cluster with CloudWatch Container Insights on by default and the Fargate capacity
providers associated, so that `aws/ecs-service` can run in it straight away.

## Usage

```hcl
module "cluster" {
  source = "../../modules/aws/ecs-cluster"

  name = "orders-prod"

  # Optional: let services that set no strategy of their own run mostly on Spot.
  default_capacity_provider_strategy = [
    { capacity_provider = "FARGATE", weight = 1, base = 1 },
    { capacity_provider = "FARGATE_SPOT", weight = 3 },
  ]

  tags = { Team = "platform" }
}

module "api" {
  source      = "../../modules/aws/ecs-service"
  cluster_arn = module.cluster.arn
  # ...
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
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_capacity_providers"></a> [capacity\_providers](#input\_capacity\_providers) | Capacity providers to associate with the cluster. Services choose among these with a capacity\_provider\_strategy. Set to [] to associate none. | `list(string)` | <pre>[<br/>  "FARGATE",<br/>  "FARGATE_SPOT"<br/>]</pre> | no |
| <a name="input_container_insights"></a> [container\_insights](#input\_container\_insights) | Enable CloudWatch Container Insights for the cluster (per-service CPU, memory, network and task metrics). | `bool` | `true` | no |
| <a name="input_default_capacity_provider_strategy"></a> [default\_capacity\_provider\_strategy](#input\_default\_capacity\_provider\_strategy) | Strategy used by services that do not set their own. Each entry's capacity\_provider must be listed in capacity\_providers. | <pre>list(object({<br/>    capacity_provider = string<br/>    weight            = number<br/>    base              = optional(number, 0)<br/>  }))</pre> | `[]` | no |
| <a name="input_execute_command_log_group_name"></a> [execute\_command\_log\_group\_name](#input\_execute\_command\_log\_group\_name) | CloudWatch log group that records ECS Exec sessions. When null, sessions are not logged. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS cluster. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the cluster. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the cluster. Pass this to aws/ecs-service as cluster\_arn. |
| <a name="output_id"></a> [id](#output\_id) | ID (ARN) of the cluster. |
| <a name="output_name"></a> [name](#output\_name) | Name of the cluster. aws/ecs-autoscaling needs this to build its resource id. |
<!-- END_TF_DOCS -->
