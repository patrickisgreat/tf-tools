# `gcp/artifact-registry`

An Artifact Registry repository — GCP's home for container images and language packages
(the rough analog of `aws/ecr`).

## Usage

```hcl
module "images" {
  source = "../../modules/gcp/artifact-registry"

  repository_id  = "services"
  location       = "us-central1"
  format         = "DOCKER"
  immutable_tags = true

  labels = { team = "platform" }
}

# Push target:
#   module.images.repository_url => us-central1-docker.pkg.dev/<project>/services
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `repository_id` | Repository id. | `string` | n/a | yes |
| `location` | Region or multi-region. | `string` | `"us"` | no |
| `format` | DOCKER, MAVEN, NPM, PYTHON, APT, YUM, GO, KFP. | `string` | `"DOCKER"` | no |
| `description` | Repository description. | `string` | `null` | no |
| `project` | GCP project (defaults to provider). | `string` | `null` | no |
| `mode` | STANDARD / REMOTE / VIRTUAL repository. | `string` | `"STANDARD_REPOSITORY"` | no |
| `kms_key_name` | CMEK key for encryption. | `string` | `null` | no |
| `immutable_tags` | Immutable tags (DOCKER only). | `bool` | `null` | no |
| `labels` | Labels to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `id` | Fully-qualified repository id. |
| `name` | Repository name. |
| `repository_url` | Docker push/pull host path (DOCKER format). |
<!-- END_TF_DOCS -->
