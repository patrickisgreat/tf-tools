# `aws/ecr`

An AWS ECR repository with sensible, secure defaults: immutable tags, scan-on-push,
encryption, and a lifecycle policy synthesized from two simple knobs (with a raw-JSON
escape hatch).

## Usage

```hcl
module "app_ecr" {
  source = "../../modules/aws/ecr"

  name                       = "team/service"
  image_tag_mutability       = "IMMUTABLE"
  scan_on_push               = true
  keep_last_n_images         = 30
  expire_untagged_after_days = 14

  tags = {
    Team        = "platform"
    Environment = "dev"
  }
}
```

Cross-account pull access via the `repository_policy` escape hatch:

```hcl
module "shared_ecr" {
  source = "../../modules/aws/ecr"
  name   = "shared/base-images"

  repository_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowPull"
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::111122223333:root" }
      Action    = ["ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage", "ecr:BatchCheckLayerAvailability"]
    }]
  })
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the ECR repository. | `string` | n/a | yes |
| `image_tag_mutability` | Tag mutability: MUTABLE or IMMUTABLE. | `string` | `"IMMUTABLE"` | no |
| `scan_on_push` | Scan images for vulnerabilities on push. | `bool` | `true` | no |
| `encryption_type` | Encryption type: AES256 or KMS. | `string` | `"AES256"` | no |
| `kms_key` | KMS key ARN when `encryption_type = KMS`. | `string` | `null` | no |
| `force_delete` | Delete the repo even if it contains images. | `bool` | `false` | no |
| `keep_last_n_images` | Keep only the most recent N images (0 disables). | `number` | `30` | no |
| `expire_untagged_after_days` | Expire untagged images older than N days (0 disables). | `number` | `14` | no |
| `lifecycle_policy` | Raw lifecycle policy JSON (overrides helpers). | `string` | `null` | no |
| `repository_policy` | Repository policy JSON (e.g. cross-account pull). | `string` | `null` | no |
| `tags` | Tags to apply to the repository. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `repository_url` | Repository URL for docker push/pull. |
| `repository_arn` | ARN of the repository. |
| `repository_name` | Name of the repository. |
| `registry_id` | Registry (account) ID. |
<!-- END_TF_DOCS -->
