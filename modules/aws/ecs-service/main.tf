locals {
  family = var.family != null ? var.family : var.name
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.family
  requires_compatibilities = [var.launch_type]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = var.container_definitions

  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name            = var.name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = var.launch_type

  enable_execute_command = var.enable_execute_command

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.lb_container_name
      container_port   = var.lb_container_port
    }
  }

  lifecycle {
    precondition {
      condition     = var.target_group_arn == null || (var.lb_container_name != null && var.lb_container_port != null)
      error_message = "When target_group_arn is set, lb_container_name and lb_container_port are required."
    }
  }

  tags = var.tags
}
