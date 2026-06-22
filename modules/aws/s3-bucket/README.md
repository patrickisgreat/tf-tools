# `aws/s3-bucket`

An S3 bucket with secure defaults: encryption on, versioning on, public access blocked,
and ACLs disabled (`BucketOwnerEnforced`). Lifecycle rules and a bucket policy are
parameterized.

Uses the modern split-resource layout (`aws_s3_bucket_*`) rather than the deprecated
inline blocks.

## Usage

```hcl
module "data" {
  source = "../../modules/aws/s3-bucket"

  bucket = "my-org-data-dev"

  lifecycle_rules = [
    {
      id              = "expire-tmp"
      prefix          = "tmp/"
      expiration_days = 30
    },
    {
      id                                 = "archive-then-expire"
      noncurrent_version_expiration_days = 90
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
        { days = 90, storage_class = "GLACIER" },
      ]
    },
  ]

  tags = { Team = "platform" }
}
```

KMS encryption with a bucket key:

```hcl
module "secure" {
  source        = "../../modules/aws/s3-bucket"
  bucket        = "my-org-secure-dev"
  sse_algorithm = "aws:kms"
  kms_key_arn   = aws_kms_key.this.arn
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- Run `make docs` (terraform-docs) to inject the inputs/outputs table here. -->

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bucket` | Globally-unique bucket name. | `string` | n/a | yes |
| `force_destroy` | Delete a non-empty bucket. | `bool` | `false` | no |
| `versioning_enabled` | Enable versioning. | `bool` | `true` | no |
| `sse_algorithm` | `AES256` or `aws:kms`. | `string` | `"AES256"` | no |
| `kms_key_arn` | KMS key ARN for `aws:kms`. | `string` | `null` | no |
| `bucket_key_enabled` | Use an S3 Bucket Key. | `bool` | `true` | no |
| `block_public_access` | Block all public access. | `bool` | `true` | no |
| `object_ownership` | Ownership / ACL mode. | `string` | `"BucketOwnerEnforced"` | no |
| `lifecycle_rules` | List of lifecycle rules. | `list(object)` | `[]` | no |
| `policy` | Bucket policy JSON. | `string` | `null` | no |
| `tags` | Tags to apply. | `map(string)` | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| `id` | Bucket name. |
| `arn` | Bucket ARN. |
| `bucket_domain_name` | Bucket domain name. |
| `bucket_regional_domain_name` | Regional bucket domain name. |
<!-- END_TF_DOCS -->
