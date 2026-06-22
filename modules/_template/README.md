# `<provider>/<name>`

One-line description of what this module provisions.

## Usage

```hcl
module "example" {
  source = "../../modules/<provider>/<name>"

  name = "my-thing"
  tags = {
    Team = "platform"
  }
}
```

See [`examples/basic`](examples/basic) for a runnable example.

<!-- BEGIN_TF_DOCS -->
<!-- terraform-docs injects the inputs/outputs table here. Run `make docs`. -->
<!-- END_TF_DOCS -->
