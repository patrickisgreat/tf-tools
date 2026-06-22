# `gcp/gcs-bucket`

A Google Cloud Storage bucket with secure defaults: uniform bucket-level access,
public access prevention enforced, and parameterized lifecycle rules.

## Usage

```hcl
module "data_bucket" {
  source = "../../modules/gcp/gcs-bucket"

  name               = "my-project-data"
  location           = "US"
  versioning_enabled = true

  lifecycle_rules = [
    {
      action    = { type = "SetStorageClass", storage_class = "NEARLINE" }
      condition = { age = 30 }
    },
    {
      action    = { type = "Delete" }
      condition = { age = 365 }
    },
  ]

  labels = {
    team = "platform"
    env  = "dev"
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Globally-unique bucket name. | `string` | n/a | yes |
| `project` | GCP project ID (defaults to provider). | `string` | `null` | no |
| `location` | Region or multi-region. | `string` | `"US"` | no |
| `storage_class` | Default storage class. | `string` | `"STANDARD"` | no |
| `uniform_bucket_level_access` | Enable UBLA. | `bool` | `true` | no |
| `public_access_prevention` | `enforced` or `inherited`. | `string` | `"enforced"` | no |
| `versioning_enabled` | Enable object versioning. | `bool` | `false` | no |
| `force_destroy` | Destroy even if non-empty. | `bool` | `false` | no |
| `kms_key_name` | CMEK key for default encryption. | `string` | `null` | no |
| `lifecycle_rules` | List of `{action, condition}` rules. | `list(object)` | `[]` | no |
| `labels` | Labels to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `name` | Bucket name. |
| `url` | Base `gs://` URL. |
| `self_link` | Bucket resource URI. |
<!-- END_TF_DOCS -->
