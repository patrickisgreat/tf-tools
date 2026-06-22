# `gcp/service-account`

A Google service account with optional project-level role bindings and (discouraged) JSON
key creation.

## Usage

```hcl
module "app_sa" {
  source = "../../modules/gcp/service-account"

  account_id   = "orders-app"
  display_name = "Orders application"

  project_roles = [
    "roles/storage.objectViewer",
    "roles/pubsub.publisher",
  ]
}

# Use the identity elsewhere:
#   member = module.app_sa.member   # "serviceAccount:orders-app@<project>.iam.gserviceaccount.com"
```

> Prefer workload identity / impersonation over `create_key = true`. Exported keys are
> long-lived credentials and a common source of leaks.

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `account_id` | Service account id (before the @). | `string` | n/a | yes |
| `display_name` | Human-readable name. | `string` | `null` | no |
| `description` | Description. | `string` | `null` | no |
| `project` | GCP project (defaults to provider). | `string` | `null` | no |
| `disabled` | Create disabled. | `bool` | `false` | no |
| `project_roles` | Project IAM roles to grant. | `list(string)` | `[]` | no |
| `create_key` | Create a JSON key (discouraged). | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| `email` | Service account email. |
| `id` | Fully-qualified id. |
| `name` | Resource name. |
| `unique_id` | Numeric unique id. |
| `member` | IAM member string. |
| `private_key` | Base64 JSON key (sensitive, only if `create_key`). |
<!-- END_TF_DOCS -->
