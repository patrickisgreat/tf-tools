# Adding a module

1. **Scaffold** from the template:
   ```bash
   make new-module DIR=aws/sns      # creates modules/aws/sns from modules/_template
   ```

2. **Fill in the four `.tf` files** following [CONVENTIONS.md](CONVENTIONS.md):
   - `versions.tf` — set `required_providers` (permissive `>=` constraints).
   - `variables.tf` — inputs with `description`, `type`, defaults, validation.
   - `main.tf` — resources + `locals`. No `provider` blocks.
   - `outputs.tf` — the identifiers callers need.

3. **Write at least one example** under `examples/basic/` that a reader can
   `terraform init && terraform plan`. The example configures the provider; the module
   does not.

4. **Generate docs**:
   ```bash
   make docs
   ```

5. **Validate locally**:
   ```bash
   make fmt
   make validate
   make lint
   ```

6. **Register it** in the catalog table in the root [README](../README.md).

7. **Open a PR.** CI runs fmt + validate + tflint + a Trivy config scan.

## Tips

- Start from the closest existing module, not a blank file — `aws/ecr` and
  `gcp/gcs-bucket` are the reference implementations.
- Keep the public surface small. Add a raw-JSON / passthrough escape hatch instead of
  modelling every nested attribute as a variable.
- If the module wraps a third-party REST API and you can't validate it in CI yet, add a
  `.validate-skip` file and mark the README **Experimental**.
