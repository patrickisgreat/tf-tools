# CLAUDE.md

Operating guidance for Claude Code (and humans) working in **tf-tools**. Read this before
making changes. For module-authoring detail see [docs/CONVENTIONS.md](docs/CONVENTIONS.md);
for the project overview see [README.md](README.md).

## What this repo is

A monorepo of reusable, parameterized **Terraform** modules (AWS, GCP, and managed AI/GPU
platforms like Replicate/Fal/Modal). Two layers:

- `modules/` — the reusable library. Provider-config-agnostic, permissively versioned.
- `environments/` — deployable root configs that wire modules together with concrete
  variables ("set vars and go").

## Toolchain & common commands

Terraform ships from the HashiCorp tap (not homebrew-core), pinned in `.terraform-version`:

```bash
brew install hashicorp/tap/terraform
brew install tflint terraform-docs pre-commit
pre-commit install
```

| Command | What it does |
|---------|--------------|
| `make fmt` | Format all Terraform in place |
| `make fmt-check` | Verify formatting (CI-friendly) |
| `make validate` | `init -backend=false` + `validate` every module/example/env (skips `.validate-skip` dirs) |
| `make test` | Run every module's `terraform test` suite against mocked providers (no credentials) |
| `make lint` | Run tflint |
| `make docs` | Regenerate module README input/output tables (terraform-docs) |
| `make catalog` | Regenerate the root README module catalog from `metadata.yaml` files |
| `make catalog-check` | Verify the catalog is up to date (CI-friendly) |
| `make new-module DIR=aws/sns` | Scaffold a new module from `modules/_template` |

**Always run `make fmt` and `make validate` before committing.**

## Git workflow

This is the core of how we work here. Treat it as a hard rule, not a suggestion.

### Branching

- `main` is always releasable and gated by CI. **Never commit feature work directly to
  `main`** — open a branch and a PR. (The only exception is the one-time repo bootstrap,
  which has no `main` to branch from yet.)
- One branch per change, named `type/short-kebab-description`:
  - `feat/aws-sns-module`
  - `fix/ecr-lifecycle-null-countunit`
  - `docs/contributing-guide`
- Keep branches short-lived. Rebase onto `main` instead of letting them drift.

### Commit often — small and atomic

- **One logical change per commit.** Each commit should leave the tree formatted and
  `make validate`-green, so history stays bisectable.
- Commit frequently. Small commits are easier to review, revert, and reason about than one
  large drop at the end.

### Conventional Commits (commitlint style)

Every commit message follows [Conventional Commits](https://www.conventionalcommits.org):

```
type(scope): subject

[optional body — what & why, wrapped ~72 cols]

[optional footer — BREAKING CHANGE: ..., Refs #123, Closes #123]
```

- **type**: `feat`, `fix`, `docs`, `chore`, `refactor`, `perf`, `test`, `ci`, `build`,
  `style`, `revert`
- **scope** (encouraged): the module or area — `aws/ecr`, `gcp`, `replicate`,
  `environments`, `ci`, `docs`
- **subject**: imperative mood, lowercase, no trailing period, ≤ ~72 chars

Examples:

```
feat(aws/ecr): add cross-account repository policy input
fix(aws/ecr): avoid null countUnit in imageCountMoreThan lifecycle rule
docs(conventions): clarify permissive version constraints for modules
chore(ci): pin terraform to 1.15.6
feat(gcp/gke-gpu-nodepool): add GPU node pool module
```

Breaking change:

```
refactor(aws/ecr)!: rename image_count to keep_last_n_images

BREAKING CHANGE: callers must rename the `image_count` variable.
```

Commit messages are linted on every PR by `.github/workflows/commitlint.yml`
(config in `commitlint.config.mjs` — it must be ESM, the action container runs under
`type: module`).

### Releases are automatic

`.github/workflows/release.yml` runs [release-please](https://github.com/googleapis/release-please)
on every push to `main`. It keeps one **release PR** open that bumps `version.txt`, updates
`CHANGELOG.md`, and lists every `feat`/`fix` since the last tag. Merging that PR creates the
`vX.Y.Z` tag and a GitHub Release. Consumers pin those tags.

- `fix:` bumps patch, `feat:` bumps minor. While we are pre-1.0, `feat!:` /
  `BREAKING CHANGE:` also bumps minor.
- `docs`, `chore`, `ci`, `test`, `refactor` never cut a release on their own.
- Never create version tags by hand and never edit `CHANGELOG.md` or `version.txt` —
  the release PR owns them. The commit *type* you choose is what decides the version.

### Small, reviewable PRs

- **One concern per PR.** Aim for small diffs (rule of thumb: < ~400 changed lines). A new
  module plus its example and docs is one coherent PR; five unrelated modules is five PRs.
- The **PR title follows the Conventional Commit format** — it becomes the squash-merge
  subject.
- PR description covers: what changed, why, how to test (`terraform plan` output when
  useful), and linked issues.
- CI must be green before merge: fmt, validate, tflint, trivy, commitlint.

### PR checklist

- [ ] `make fmt` is clean, and `make validate` and `make test` pass
- [ ] The module has a `tests/*.tftest.hcl` suite covering its secure defaults and every
      `validation` block — and you confirmed an assertion actually fails when the module
      is broken on purpose (see [docs/TESTING.md](docs/TESTING.md))
- [ ] `make docs` re-run if any variables/outputs changed
- [ ] An `examples/basic` example exists/updated and validates
- [ ] Module `README.md` is updated, `metadata.yaml` is accurate, and `make catalog` re-run
      (never hand-edit the catalog table — it's generated)
- [ ] No secrets, `*.tfvars` (only `*.tfvars.example`), state, or `.terraform/` committed
- [ ] New experimental API-wrapper modules carry a `.validate-skip` file and an
      **Experimental** README banner

## Module conventions (summary)

Full detail in [docs/CONVENTIONS.md](docs/CONVENTIONS.md). The essentials:

- A module is one directory with `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`,
  `README.md`, and an `examples/` dir.
- Modules **never** declare `provider` blocks or hardcode region/project/account — the root
  config configures providers. Modules use permissive `>=` constraints; `environments/` pin
  with `~>` and commit `.terraform.lock.hcl`.
- Every variable and output has a `description`. Validate inputs where it's cheap. Default
  to the secure choice.

## Gotchas

- Never commit state (`*.tfstate*`), real `*.tfvars`, or `.terraform/` — they're gitignored;
  don't force-add them.
- Modules that wrap live third-party REST APIs (Replicate/Fal/Modal) can't be validated in
  CI yet — they carry a `.validate-skip` file and an Experimental banner until verified
  against the real API.
- `make validate` runs with `-backend=false`. Real applies happen from
  `environments/<env>/` with the backend configured.
