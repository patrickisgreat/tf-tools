# tf-tools

A curated library of reusable, parameterized **Terraform modules** for spinning up
infrastructure across clouds and platforms — AWS, GCP, and managed AI/GPU platforms
(Replicate, Fal, Modal). Import a module, set a handful of variables in your root
config / `tfvars`, and go.

Inspired by the internal `tf-tools` monorepo pattern: small, composable, well-documented
modules that each do one thing well.

## Layout

```
tf-tools/
├── modules/                 # the reusable module library (the product)
│   ├── _template/           # copy this to start a new module
│   ├── aws/
│   │   └── ecr/             # AWS ECR repository  (flagship example)
│   ├── gcp/
│   │   └── gcs-bucket/      # GCS bucket          (flagship example)
│   └── replicate/
│       └── deployment/      # Replicate deployment (EXPERIMENTAL API wrapper)
├── environments/            # deployable root configs ("set vars and go")
│   └── dev/                 # example env: backend + providers + tfvars
├── docs/
│   ├── CONVENTIONS.md       # how modules are written
│   └── ADDING_A_MODULE.md   # step-by-step to add a new module
├── .github/workflows/ci.yml # fmt + validate + tflint + security scan
├── .pre-commit-config.yaml  # local enforcement of the same checks
├── .tflint.hcl
└── Makefile                 # make fmt / validate / lint / docs
```

## Two layers

1. **`modules/`** — the library. Each module is provider-config-agnostic (it declares
   `required_providers` but never a `provider` block), permissively versioned, and
   documented. This is what gets reused.
2. **`environments/`** — the composition layer. Each environment is a root Terraform
   config that configures the backend + providers and wires modules together with
   concrete variables. This is what you `terraform apply`.

## Quickstart

```bash
# 1. Install the toolchain (see .terraform-version for the pinned version).
#    Terraform ships from the HashiCorp tap, not homebrew-core.
brew install hashicorp/tap/terraform
brew install tflint terraform-docs pre-commit              # macOS
pre-commit install                                         # enable git hooks

# 2. Try an example module in isolation
cd modules/aws/ecr/examples/basic
terraform init
terraform plan

# 3. Or deploy an environment
cd environments/dev
cp terraform.tfvars.example terraform.tfvars   # edit values
# edit backend.tf (or pass -backend-config) to point at your state bucket
terraform init
terraform plan
```

## Module catalog

| Module | Provider | Status | Description |
|--------|----------|--------|-------------|
| [`aws/ecr`](modules/aws/ecr) | AWS | stable | ECR repository with scanning, encryption, lifecycle + repo policy |
| [`aws/s3-bucket`](modules/aws/s3-bucket) | AWS | stable | S3 bucket with SSE, versioning, public-access block, lifecycle rules |
| [`gcp/gcs-bucket`](modules/gcp/gcs-bucket) | GCP | stable | GCS bucket with UBLA, versioning, lifecycle rules, CMEK |
| [`replicate/deployment`](modules/replicate/deployment) | Replicate (REST) | **experimental** | Managed AI deployment via the `restapi` provider |

## Conventions

See [docs/CONVENTIONS.md](docs/CONVENTIONS.md). The short version:

- One module = one directory with `main.tf`, `variables.tf`, `outputs.tf`,
  `versions.tf`, `README.md`.
- Reusable modules use **permissive** version constraints (`>=`); root configs pin
  exactly and commit `.terraform.lock.hcl`.
- Every variable and output has a `description`. Inputs validate where it's cheap.
- Modules never declare `provider` blocks — the root config does.

## Roadmap

The first slice ships the scaffold + 3 exemplar modules. Next candidates (rebuilding the
`tf-tools` catalog): `aws/{sns,sqs,firehose,ecs-service,iam-role,s3-bucket}`,
`gcp/{pubsub,service-account,artifact-registry}`, cloud-native GPU compute
(`aws/ecs-gpu`, `gcp/gke-gpu-nodepool`), and managed-platform wrappers for Fal / Modal.

## License

MIT — see [LICENSE](LICENSE).
