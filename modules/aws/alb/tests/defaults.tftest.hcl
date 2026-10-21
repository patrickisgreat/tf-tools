# `terraform test` suite for aws/alb. Runs against a mocked AWS provider, so it
# needs no credentials and creates nothing. See docs/TESTING.md.

mock_provider "aws" {}

variables {
  name       = "tf-tools-test"
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-aaaaaaaa", "subnet-bbbbbbbb"]
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = aws_lb.this.drop_invalid_header_fields
    error_message = "Invalid header fields must be dropped: forwarding them lets malformed requests reach targets and is a request-smuggling vector."
  }

  assert {
    condition     = aws_lb.this.desync_mitigation_mode == "defensive"
    error_message = "Desync mitigation must stay at least defensive; monitor mode only logs ambiguous requests instead of blocking them."
  }

  assert {
    condition     = aws_lb_target_group.this.target_type == "ip"
    error_message = "Targets are registered by IP, which is what Fargate tasks in awsvpc mode require."
  }

  assert {
    condition     = length(aws_lb_listener.https) == 0
    error_message = "No HTTPS listener should be created without a certificate; a listener with no certificate fails to apply."
  }

  assert {
    condition     = one(aws_lb_listener.http.default_action).type == "forward"
    error_message = "Without a certificate the HTTP listener must forward to the target group, otherwise nothing can reach the service."
  }

  assert {
    condition     = length([for r in aws_security_group.this.ingress : r if r.from_port == 443]) == 0
    error_message = "Port 443 must not be opened on the security group when there is no HTTPS listener to answer on it."
  }
}

run "certificate_enables_https_and_redirects_http" {
  command = plan

  variables {
    certificate_arn = "arn:aws:acm:us-east-1:111122223333:certificate/abc"
  }

  assert {
    condition     = length(aws_lb_listener.https) == 1
    error_message = "A certificate must create the HTTPS listener."
  }

  assert {
    condition     = aws_lb_listener.https[0].ssl_policy == "ELBSecurityPolicy-TLS13-1-2-2021-06"
    error_message = "The default TLS policy must require TLS 1.2 or newer; older policies accept TLS 1.0 and 1.1."
  }

  assert {
    condition     = one(aws_lb_listener.http.default_action).type == "redirect"
    error_message = "With a certificate, plain HTTP must redirect to HTTPS rather than serve traffic in the clear."
  }

  assert {
    condition     = one(one(aws_lb_listener.http.default_action).redirect).status_code == "HTTP_301"
    error_message = "The HTTP to HTTPS redirect must be permanent so that clients cache it."
  }

  assert {
    condition     = length([for r in aws_security_group.this.ingress : r if r.from_port == 443]) == 1
    error_message = "Port 443 must be opened on the security group once there is an HTTPS listener."
  }
}

run "health_check_and_grpc_are_wired" {
  command = plan

  variables {
    target_protocol_version = "GRPC"
    target_port             = 9090
    health_check = {
      path    = "/grpc.health.v1.Health/Check"
      matcher = "0"
    }
  }

  assert {
    condition     = aws_lb_target_group.this.protocol_version == "GRPC"
    error_message = "target_protocol_version must reach the target group."
  }

  assert {
    condition     = aws_lb_target_group.this.port == 9090
    error_message = "target_port must reach the target group."
  }

  assert {
    condition     = one(aws_lb_target_group.this.health_check).path == "/grpc.health.v1.Health/Check" && one(aws_lb_target_group.this.health_check).matcher == "0"
    error_message = "Supplied health check fields must override the defaults while unspecified fields keep theirs."
  }

  assert {
    condition     = one(aws_lb_target_group.this.health_check).interval == 15
    error_message = "Health check fields that were not supplied must keep their defaults."
  }
}

run "access_logs_are_opt_in" {
  command = plan

  variables {
    access_logs_bucket = "example-alb-logs"
    access_logs_prefix = "orders"
  }

  assert {
    condition     = one(aws_lb.this.access_logs).enabled && one(aws_lb.this.access_logs).bucket == "example-alb-logs"
    error_message = "A supplied access_logs_bucket must enable access logging to that bucket."
  }
}

# --- input validation -------------------------------------------------------

run "rejects_name_over_32_chars" {
  command = plan
  variables {
    name = "this-load-balancer-name-is-far-too-long"
  }
  expect_failures = [var.name]
}

run "rejects_single_subnet" {
  command = plan
  variables {
    subnet_ids = ["subnet-aaaaaaaa"]
  }
  expect_failures = [var.subnet_ids]
}

run "rejects_unknown_protocol_version" {
  command = plan
  variables {
    target_protocol_version = "HTTP3"
  }
  expect_failures = [var.target_protocol_version]
}
