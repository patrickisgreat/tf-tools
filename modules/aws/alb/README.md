# `aws/alb`

An application load balancer, its security group, one IP target group and the listeners
to reach it. Supply a certificate and you get HTTPS on 443 with port 80 redirecting to it;
leave it out and port 80 forwards directly, which is what an internal service behind a
mesh or a development environment wants.

Secure by default: invalid header fields are dropped, desync mitigation is defensive, and
the TLS policy is TLS 1.2+ with 1.3 preferred. gRPC targets are supported through
`target_protocol_version = "GRPC"`.

## Usage

```hcl
module "alb" {
  source = "../../modules/aws/alb"

  name       = "orders-prod"
  vpc_id     = module.vpc.id
  subnet_ids = module.vpc.public_subnet_ids

  certificate_arn = aws_acm_certificate.orders.arn
  target_port     = 8080
  health_check    = { path = "/-/health" }

  tags = { Team = "platform" }
}

module "api" {
  source = "../../modules/aws/ecs-service"
  # ...
  target_group_arn  = module.alb.target_group_arn
  lb_container_name = "app"
  lb_container_port = 8080
}

resource "aws_security_group_rule" "api_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.api.id
  source_security_group_id = module.alb.security_group_id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
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
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | S3 bucket to write access logs to. null disables access logging. | `string` | `null` | no |
| <a name="input_access_logs_prefix"></a> [access\_logs\_prefix](#input\_access\_logs\_prefix) | Key prefix for access logs within access\_logs\_bucket. | `string` | `null` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ACM certificate for an HTTPS listener on 443. When set, port 80 redirects to 443; when null, port 80 forwards to the target group. | `string` | `null` | no |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | Seconds to drain in-flight requests from a target before it is removed. | `number` | `30` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Refuse to delete the load balancer through the API. Turn on for production once the environment is stable. | `bool` | `false` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | Target group health check. matcher is an HTTP status range for HTTP targets or a gRPC status range for GRPC targets. | <pre>object({<br/>    path                = optional(string, "/health")<br/>    interval            = optional(number, 15)<br/>    timeout             = optional(number, 5)<br/>    healthy_threshold   = optional(number, 3)<br/>    unhealthy_threshold = optional(number, 2)<br/>    matcher             = optional(string, "200")<br/>  })</pre> | `{}` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | Seconds a connection may be idle before the load balancer closes it. | `number` | `60` | no |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | CIDR ranges allowed to reach the listeners. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_internal"></a> [internal](#input\_internal) | Keep the load balancer reachable only from inside the VPC. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the load balancer and its target group (at most 32 characters, ALB naming rules). | `string` | n/a | yes |
| <a name="input_ssl_policy"></a> [ssl\_policy](#input\_ssl\_policy) | TLS negotiation policy for the HTTPS listener. | `string` | `"ELBSecurityPolicy-TLS13-1-2-2021-06"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnets for the load balancer nodes, in at least two availability zones. Public subnets for an internet-facing balancer. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to every resource. | `map(string)` | `{}` | no |
| <a name="input_target_port"></a> [target\_port](#input\_target\_port) | Port the targets listen on. | `number` | `8080` | no |
| <a name="input_target_protocol_version"></a> [target\_protocol\_version](#input\_target\_protocol\_version) | Protocol used to talk to the targets: HTTP1, HTTP2 or GRPC. | `string` | `"HTTP1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to create the load balancer, target group and security group in. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the load balancer. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | ARN suffix of the load balancer, the LoadBalancer dimension of its CloudWatch metrics. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | Hostname of the load balancer. |
| <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn) | ARN of the port 80 listener. |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | ARN of the port 443 listener, or null when no certificate was supplied. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group of the load balancer. Allow this as the source on the targets' security group. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | ARN of the target group. Pass this to aws/ecs-service as target\_group\_arn. |
| <a name="output_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#output\_target\_group\_arn\_suffix) | ARN suffix of the target group, the TargetGroup dimension of its CloudWatch metrics. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | Route 53 hosted zone id of the load balancer, for alias records. |
<!-- END_TF_DOCS -->
