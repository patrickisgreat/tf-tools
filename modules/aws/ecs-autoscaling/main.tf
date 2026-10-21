locals {
  name = "${var.cluster_name}-${var.service_name}"

  # One target-tracking policy per enabled metric. Keys become the policy name
  # suffix and the key of the policy_arns output.
  policies = merge(
    var.cpu_target_percent == null ? {} : {
      cpu = {
        target_value           = var.cpu_target_percent
        predefined_metric_type = "ECSServiceAverageCPUUtilization"
        resource_label         = null
      }
    },
    var.memory_target_percent == null ? {} : {
      memory = {
        target_value           = var.memory_target_percent
        predefined_metric_type = "ECSServiceAverageMemoryUtilization"
        resource_label         = null
      }
    },
    var.requests_per_target == null ? {} : {
      requests = {
        target_value           = var.requests_per_target
        predefined_metric_type = "ALBRequestCountPerTarget"
        resource_label         = "${var.alb_arn_suffix}/${var.target_group_arn_suffix}"
      }
    },
  )
}

resource "aws_appautoscaling_target" "this" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  tags = var.tags
}

resource "aws_appautoscaling_policy" "this" {
  for_each = local.policies

  name               = "${local.name}-${each.key}"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.this.service_namespace
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value       = each.value.target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
    disable_scale_in   = var.disable_scale_in

    predefined_metric_specification {
      predefined_metric_type = each.value.predefined_metric_type
      resource_label         = each.value.resource_label
    }
  }
}
