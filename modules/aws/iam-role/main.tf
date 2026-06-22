locals {
  # Build the trust policy from the convenience inputs unless a full policy was
  # supplied. Each statement is encoded independently so Terraform doesn't unify
  # the differing Principal shapes (Service vs AWS) and inject null keys.
  service_statement = length(var.trusted_role_services) > 0 ? jsonencode({
    Effect    = "Allow"
    Principal = { Service = var.trusted_role_services }
    Action    = "sts:AssumeRole"
  }) : null

  arn_statement = length(var.trusted_role_arns) > 0 ? jsonencode({
    Effect    = "Allow"
    Principal = { AWS = var.trusted_role_arns }
    Action    = "sts:AssumeRole"
  }) : null

  trust_statements = [for s in [local.service_statement, local.arn_statement] : s if s != null]

  effective_assume_role_policy = (
    var.assume_role_policy != null
    ? var.assume_role_policy
    : "{\"Version\": \"2012-10-17\", \"Statement\": [${join(", ", local.trust_statements)}]}"
  )
}

resource "aws_iam_role" "this" {
  name                  = var.name
  path                  = var.path
  description           = var.description
  assume_role_policy    = local.effective_assume_role_policy
  max_session_duration  = var.max_session_duration
  permissions_boundary  = var.permissions_boundary
  force_detach_policies = var.force_detach_policies
  tags                  = var.tags

  lifecycle {
    precondition {
      condition     = var.assume_role_policy != null || (length(var.trusted_role_services) + length(var.trusted_role_arns)) > 0
      error_message = "Provide assume_role_policy, or at least one of trusted_role_services / trusted_role_arns to build the trust policy."
    }
  }
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies

  name   = each.key
  role   = aws_iam_role.this.id
  policy = each.value
}
