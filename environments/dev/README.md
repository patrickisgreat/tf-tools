# environments/dev

Example deployable root config. This is the composition layer: it configures the
backend + providers and wires library modules together with concrete variables.

## Deploy

```bash
cd environments/dev

# 1. Point the backend at your state bucket (edit backend.tf or use -backend-config).
# 2. Provide values:
cp terraform.tfvars.example terraform.tfvars   # then edit

terraform init
terraform plan
terraform apply
```

## Notes

- `terraform.tfvars` is gitignored (it may hold environment-specific values). Commit
  `.terraform.lock.hcl` once generated so applies are reproducible.
- Provider versions are pinned in `versions.tf`; modules under `modules/` use
  permissive constraints by design.
- To stamp out a new environment, copy this directory to `environments/<name>/` and
  change `backend.tf` (`key`) plus the tfvars.
