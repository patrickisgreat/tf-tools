# `replicate/deployment` — ⚠️ EXPERIMENTAL

> **Status: experimental / reference.** Replicate has no first-class Terraform
> provider. This module models a Replicate *deployment* as a REST object via the
> generic [`Mastercard/restapi`](https://registry.terraform.io/providers/Mastercard/restapi/latest)
> provider. It demonstrates the **managed-platform-via-API pattern** that also applies
> to Fal and Modal. It is **excluded from CI validation** (`.validate-skip`) and the
> exact paths/methods must be verified against the live API before production use.

## Why it looks different

Cloud modules (`aws/ecr`, `gcp/gcs-bucket`) sit on mature providers that map resources
to API objects for you. Replicate doesn't, so we drive its HTTP API directly. The
trade-offs: no drift detection beyond what the API returns, and CRUD path/verb quirks
you have to spell out (Replicate creates at `/v1/deployments` but reads/updates at
`/v1/deployments/{owner}/{name}`, and updates use `PATCH`).

## Provider setup (in the root config, not the module)

```hcl
provider "restapi" {
  uri                  = "https://api.replicate.com"
  write_returns_object = true

  headers = {
    Authorization = "Token ${var.replicate_api_token}" # sensitive; pass via TF_VAR_replicate_api_token
    Content-Type  = "application/json"
  }
}
```

## Usage

```hcl
module "sdxl" {
  source = "../../modules/replicate/deployment"

  owner         = "my-account"
  name          = "sdxl-prod"
  model         = "stability-ai/sdxl"
  version_id    = "7762fd07cf82c948538e41f63f77d685e02b063e37e496e96eefd46c929f9bdc"
  hardware      = "gpu-a40-large"
  min_instances = 0
  max_instances = 3
}
```

## Before relying on it

1. Confirm the request body fields against the
   [deployments.create API](https://replicate.com/docs/reference/http#deployments.create).
2. Confirm `restapi_object` argument names (`create_path`, `read_path`, `update_method`,
   `path`, `data`, `id_attribute`) against the current provider docs.
3. Apply against a throwaway deployment, then run `terraform plan` again to check for
   perpetual diffs (a common rough edge with generic REST providers).
4. Remove `.validate-skip` once it round-trips cleanly.

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs table injected by `make docs` once this module graduates. -->
<!-- END_TF_DOCS -->
