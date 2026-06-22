# Module conventions

These rules keep the library consistent and composable. They mirror the HashiCorp
"standard module structure" with a few opinions added.

## Directory structure

Every module lives at `modules/<provider>/<name>/` and contains:

| File | Purpose |
|------|---------|
| `main.tf` | Resources and `locals`. |
| `variables.tf` | All inputs. Every variable has a `description` and `type`. |
| `outputs.tf` | All outputs. Every output has a `description`. |
| `versions.tf` | `required_version` + `required_providers` (no `provider` blocks). |
| `README.md` | Usage + a terraform-docs-generated input/output table. |
| `examples/<name>/` | At least one runnable example (`examples/basic/`). |

## Versioning

Reusable modules are consumed in many contexts, so they must not over-constrain.

- **Modules** (`modules/**`): permissive lower bounds only.
  ```hcl
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.40" }
  }
  ```
- **Root configs** (`environments/**`): pin with `~>` (or exact) and **commit
  `.terraform.lock.hcl`** so applies are reproducible.

## Providers

Modules **never** declare a `provider` block and never hardcode `region`, `project`,
credentials, or account IDs. The root config configures providers and passes them in.
If a module needs a specific provider configuration, expose it via
[`configuration_aliases`](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
in `required_providers`.

## Variables

- `description` and explicit `type` are mandatory.
- Provide sensible, **secure-by-default** defaults (e.g. `IMMUTABLE` tags, encryption on,
  public access blocked). Make the safe choice the default.
- Add `validation` blocks for cheap correctness checks (enums, name regexes, ranges).
- Prefer a small number of high-level knobs plus one escape hatch (e.g. a raw
  `*_policy` JSON string) over exposing every primitive.
- Required inputs have no `default`. Optional inputs always do.

## Naming

- Resources use `this` when a module manages a single primary resource:
  `resource "aws_ecr_repository" "this"`.
- Variables and outputs are `snake_case`.
- Tag/label inputs are named `tags` (AWS) / `labels` (GCP) and are merged, never
  overwritten wholesale.

## Outputs

Expose the identifiers a caller actually needs to wire things together — names, ARNs,
URLs, IDs. Don't echo back inputs the caller already has.

## Documentation

The input/output tables in each `README.md` are generated. Regenerate with:

```bash
make docs        # all modules
# or one module:
terraform-docs markdown table --output-file README.md --output-mode inject modules/aws/ecr
```

Keep the hand-written "Usage" section above the `<!-- BEGIN_TF_DOCS -->` marker.

## Experimental modules

A module that can't yet be validated in CI (e.g. it wraps a live third-party REST API
with no test fixture) carries a `.validate-skip` file and an **Experimental** banner in
its README. Remove the marker once it's verified.
