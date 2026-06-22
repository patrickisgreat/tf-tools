# `aws/ecs-service`

A Fargate (or EC2) ECS service plus its task definition. You bring the cluster, networking,
and IAM roles (compose with `aws/iam-role`); this module runs your containers.

Container definitions are passed as a JSON string (the standard escape hatch) so you keep
full control of the container spec.

## Usage

```hcl
module "api" {
  source = "../../modules/aws/ecs-service"

  name        = "orders-api"
  cluster_arn = aws_ecs_cluster.main.arn

  cpu    = "512"
  memory = "1024"

  execution_role_arn = module.execution_role.arn
  task_role_arn      = module.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/orders:latest"
      essential = true
      portMappings = [{ containerPort = 8080, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/orders-api"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "app"
        }
      }
    }
  ])

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.api.id]

  target_group_arn  = aws_lb_target_group.api.arn
  lb_container_name = "app"
  lb_container_port = 8080

  desired_count = 3
  tags          = { Team = "platform" }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | ECS service name. | `string` | n/a | yes |
| `family` | Task definition family (defaults to name). | `string` | `null` | no |
| `cluster_arn` | Cluster ARN/name. | `string` | n/a | yes |
| `container_definitions` | Container definitions JSON. | `string` | n/a | yes |
| `launch_type` | `FARGATE` or `EC2`. | `string` | `"FARGATE"` | no |
| `cpu` | Task CPU units. | `string` | `"256"` | no |
| `memory` | Task memory MiB. | `string` | `"512"` | no |
| `desired_count` | Number of tasks. | `number` | `1` | no |
| `execution_role_arn` | Task execution role ARN. | `string` | `null` | no |
| `task_role_arn` | Task role ARN. | `string` | `null` | no |
| `subnet_ids` | Subnets for awsvpc ENI. | `list(string)` | n/a | yes |
| `security_group_ids` | Security groups. | `list(string)` | `[]` | no |
| `assign_public_ip` | Assign public IP. | `bool` | `false` | no |
| `target_group_arn` | LB target group ARN. | `string` | `null` | no |
| `lb_container_name` | Container for the LB. | `string` | `null` | no |
| `lb_container_port` | Container port for the LB. | `number` | `null` | no |
| `enable_execute_command` | Enable ECS Exec. | `bool` | `false` | no |
| `deployment_minimum_healthy_percent` | Min healthy % on deploy. | `number` | `100` | no |
| `deployment_maximum_percent` | Max % on deploy. | `number` | `200` | no |
| `tags` | Tags to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `service_name` | Service name. |
| `service_id` | Service ID/ARN. |
| `task_definition_arn` | Task definition ARN. |
| `task_definition_family` | Task definition family. |
| `task_definition_revision` | Current revision. |
<!-- END_TF_DOCS -->
