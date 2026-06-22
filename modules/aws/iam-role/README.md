# `aws/iam-role`

An IAM role with a trust policy you can either hand in as raw JSON or build from lists of
trusted services / principal ARNs, plus managed-policy attachments and inline policies.

## Usage

ECS task role trusting a service principal, with a managed policy and an inline policy:

```hcl
module "task_role" {
  source = "../../modules/aws/iam-role"

  name                  = "orders-task-role"
  trusted_role_services = ["ecs-tasks.amazonaws.com"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
  ]

  inline_policies = {
    s3-read = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["arn:aws:s3:::my-bucket/*"]
      }]
    })
  }

  tags = { Team = "platform" }
}
```

Cross-account role with a full custom trust policy:

```hcl
module "cross_account" {
  source = "../../modules/aws/iam-role"
  name   = "deployer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::111122223333:root" }
      Action    = "sts:AssumeRole"
      Condition = { StringEquals = { "sts:ExternalId" = "abc123" } }
    }]
  })
}
```

Provide `assume_role_policy`, or at least one of `trusted_role_services` /
`trusted_role_arns` — otherwise a precondition fails with a clear message.

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Role name. | `string` | n/a | yes |
| `path` | Role path. | `string` | `"/"` | no |
| `description` | Role description. | `string` | `null` | no |
| `assume_role_policy` | Full trust policy JSON (overrides the helpers). | `string` | `null` | no |
| `trusted_role_services` | Service principals that may assume the role. | `list(string)` | `[]` | no |
| `trusted_role_arns` | Principal ARNs that may assume the role. | `list(string)` | `[]` | no |
| `managed_policy_arns` | Managed policy ARNs to attach. | `list(string)` | `[]` | no |
| `inline_policies` | Map of name → inline policy JSON. | `map(string)` | `{}` | no |
| `permissions_boundary` | Permissions boundary policy ARN. | `string` | `null` | no |
| `max_session_duration` | Max session seconds (3600-43200). | `number` | `3600` | no |
| `force_detach_policies` | Force-detach policies on destroy. | `bool` | `false` | no |
| `tags` | Tags to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `arn` | Role ARN. |
| `name` | Role name. |
| `id` | Role ID (name). |
| `unique_id` | Stable unique role identifier. |
<!-- END_TF_DOCS -->
