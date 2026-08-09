# Roadmap

**Goal:** deploy any kind of application to AWS or GCP — Go, Python, Node/TypeScript,
Java, Kotlin, Rust, C++, C#/.NET, Swift, GraphQL and REST/gRPC APIs, AI/ML workloads —
on containers and Fargate with real autoscaling, backed by databases (SQL and NoSQL),
data lakes, and ETL pipelines. With great docs, modularity, reusability, and
maintainability.

This document is how we get there. Update it in the same PR that lands a milestone.

Legend: ✅ done · 🟡 in progress · ⬜ not started

---

## The core insight: archetypes, not languages

The language list is long and will keep growing. Building a module per language would be
a treadmill. **Infrastructure cares about runtime shape, not source language** — and
nearly every language on the list collapses into the same handful of shapes.

| Language / runtime | Packaging | Archetype |
|---|---|---|
| Go, Rust, C++ | static binary → distroless/scratch image | **container-service** |
| Java, Kotlin (JVM) | JAR/fat-JAR → JRE image | **container-service** (JVM heap + startup-probe knobs) |
| C#, .NET | self-contained publish → image | **container-service** |
| Node, TypeScript, Python | image (or zip for functions) | **container-service** or **serverless-function** |
| GraphQL (Apollo, gqlgen, Hot Chocolate, Strawberry) | image | **container-service**; managed alternative (AppSync) |
| REST / gRPC APIs | image | **container-service** + edge (gRPC needs HTTP/2-capable ingress) |
| Python ML / inference | image + GPU | **ml-inference** / **ml-training** |
| Static SPA / SSG | bundle | **static-site** |
| Swift (iOS), Kotlin (Android) | app bundle — *not server-deployed* | **mobile-backend** + artifact distribution |

One well-built container-service archetype covers nine of the languages above. That is
where the leverage is, and it is why Track A comes first.

**The honest caveat on mobile:** Swift and Android/Kotlin apps do not deploy to Fargate.
What they need from this repo is their *server side* — an API, auth, push delivery, object
storage + CDN, and a signed-artifact distribution path. Track F builds that, and calls it
what it is rather than pretending an iOS app is a deployable workload.

---

## Architecture: three layers

```
stacks/     archetypes — a whole working system from a handful of variables
            e.g. stacks/container-service-aws = network + registry + Fargate +
            ALB + autoscaling + logs + alarms + database, wired together

modules/    the library, in two kinds (to be declared as `kind:` in metadata.yaml
            once the first composite lands):
              primitive — one resource family, one job   (today's 12)
              composite — a coherent capability built from primitives
                          e.g. aws/fargate-service = ECS service + task def +
                          ALB target group + autoscaling policies + log group

environments/  deployable root configs that instantiate stacks with real values
```

Primitives stay boring and reusable. Composites carry the opinions (secure defaults, sane
autoscaling, alarms wired up). Stacks are the "set five variables and go" surface. A
consumer can enter at any layer — that's the modularity requirement, made concrete.

---

## Where we are (2026-08-09)

12 primitive modules on `main`, all `terraform validate`-clean, documented with generated
terraform-docs tables, landed through small conventional-commit PRs with green CI.

| Area | State |
|------|-------|
| Modules | 12 primitives (7 AWS, 4 GCP, 1 experimental Replicate) |
| Composites / stacks | none |
| CI | fmt · catalog · validate · tflint · trivy (non-blocking) · commitlint |
| **Tests** | **none** |
| **Releases / versioning** | **none — no tags, consumers cannot pin** |
| **Networking primitives** | **none — nothing can actually run yet** |
| **Policy gating** | **trivy runs with `exit-code: 0` — it reports, it does not gate** |

Honest summary: the repo has good *shape* and no *proof*, and it cannot yet deploy an
application because there is no network, no compute composite, and no database. `terraform
validate` only checks that HCL parses. It does not check that a module produces what it
claims or that its "secure defaults" are secure.

---

## Phase 0 — Repair drift ✅

- ✅ Sync `main` (was 26 commits behind; all nine module PRs had merged)
- ✅ Restore three catalog rows lost to merge conflicts
- ✅ **Generate** the catalog from per-module `metadata.yaml` so parallel module PRs stop
  conflicting on a shared table

---

## Phase 1 — Foundations 🟡

Horizontal work, done once, that makes a 60-module library maintainable instead of a
liability. Everything after this depends on it.

### 1a. Native `terraform test` harness ⬜

Terraform 1.6 shipped `terraform test`; 1.7 shipped `mock_provider`. Together they plan a
module against mocked providers with **no credentials and no real infrastructure** — so
the whole suite runs in CI on every PR.

Every module gets `tests/*.tftest.hcl` asserting:

- **Secure defaults** — the *default* configuration is the safe one (encryption on, public
  access blocked, immutable tags, UBLA enforced). Conventions claim this; tests make it true.
- **Input validation** — `expect_failures` on every `validation` block.
- **Conditional wiring** — optional resources appear and disappear with their toggle.
- **Outputs** — the identifiers callers wire together are populated.

Ships `make test`, a CI job, and a starter test in `_template` so new modules are born tested.

### 1b. Module interface standard ⬜

The single biggest reusability lever, and the thing that makes composition possible: every
module in the library should feel like the same module. `docs/INTERFACE.md` fixes the
contract — naming (`name` / `name_prefix`), tagging (`tags` / `labels`, always merged),
the standard output set every compute module exposes, how modules accept a network, how
secrets are passed (never as plain variables). Then retrofit the existing 12.

Composition only works if the shapes line up. Writing this down before Track A is what
keeps stacks from becoming glue code.

### 1c. Turn on the linting we already configured ⬜

`.tflint.hcl` has the AWS and Google rulesets commented out — deep provider checks
(invalid instance types, malformed ARNs) are off. Enable, pin, fix the fallout.

### 1d. Make security scanning blocking ⬜

`trivy` runs with `exit-code: "0"` — findings print and are ignored. Add **checkov**, fail
on HIGH/CRITICAL, and keep a baseline where every suppression carries a written
justification. A suppression without a reason is a lie.

### 1e. Release engineering ⬜

Today a consumer's only option is a `git::` source on a moving `main`. That is a shared
folder, not a library.

- Per-module tags (`aws/ecr/v1.2.0`) so modules version independently
- Changelog via release-please or git-cliff, driven off the conventional commits we
  already enforce
- `docs/CONSUMING.md` — how to pin, how to upgrade, what `BREAKING CHANGE:` means
- Deprecation window policy for renamed variables

### 1f. CI hardening ⬜

Concurrency groups so superseded runs cancel · third-party actions pinned to SHAs ·
provider plugin cache (12+ `init`s and growing) · Renovate for providers, actions, and
pre-commit revs.

---

## Delivery tracks

After Phase 1, work proceeds in **vertical slices**. Each track ships primitives →
composite → stack → runnable example → docs, so every track ends with something you can
actually deploy. Tracks are independently shippable; A and 0 come first because everything
else needs them.

### Track 0 — Landing zone ⬜

Nothing runs without a network. This is the prerequisite for every compute track.

- `aws/vpc` — subnets across AZs, NAT (with a single-NAT cost escape hatch), flow logs
- `aws/security-group` — composable rule sets
- `gcp/vpc` — subnets, Cloud NAT, Serverless VPC connector
- `aws/secrets` / `gcp/secret-manager` — secret storage + the IAM to read it
- `aws/observability-baseline` / `gcp/observability-baseline` — log retention, dashboards,
  alarm topics
- OIDC CI identity: `aws/github-oidc-role`, `gcp/workload-identity-federation` — deploy
  from GitHub Actions with zero long-lived keys

### Track A — Containerized services (the 80% path) ⬜

Covers Go, Rust, C++, Java, Kotlin, C#/.NET, Node, Python, and both REST and GraphQL.

- `aws/fargate-service` **(composite)** — ECS service + task definition + ALB target group
  + **autoscaling** (CPU/memory target tracking, request-count-per-target, scheduled
  min-capacity) + log group + alarms + rollback-on-failure deployment circuit breaker
- `aws/alb` — listeners, TLS, WAF hook, gRPC/HTTP2 target support
- `gcp/cloud-run-service` **(composite)** — the GCP-native equivalent, concurrency-based
  autoscaling, min instances to control cold starts
- `gcp/load-balancer` — global HTTPS LB, managed certs, Cloud CDN
- `stacks/container-service-{aws,gcp}` — network + registry + service + edge + autoscaling
  + logs + optional database, from a handful of variables
- Language build profiles in docs: image guidance per runtime (distroless for Go/Rust,
  JVM heap and startup probes for Java/Kotlin, .NET self-contained trimming, Python
  wheel/uv layering) — documentation, not modules, so it does not become a treadmill

Autoscaling gets first-class treatment here, not an afterthought: target-tracking policies,
warm-pool/min-capacity, scale-in protection during deploys, and documented defaults per
workload shape (bursty API vs steady worker vs queue consumer).

### Track B — Serverless & API edge ⬜

- `aws/lambda-function`, `aws/api-gateway-http`, `aws/appsync-graphql`
- `gcp/cloud-function`, `gcp/api-gateway`
- `aws/eventbridge-rule`, `gcp/cloud-scheduler`
- `stacks/serverless-api-{aws,gcp}`

### Track C — Databases ⬜

- SQL: `aws/rds-postgres`, `aws/aurora-serverless-v2`, `gcp/cloud-sql-postgres`
- NoSQL: `aws/dynamodb-table`, `gcp/firestore`, `gcp/bigtable`
- Cache: `aws/elasticache-redis`, `gcp/memorystore`
- Search: `aws/opensearch`
- Every one with encryption, private networking, automated backups, and PITR **on by
  default** — plus the connection wiring (secret + security group + IAM) that makes
  attaching one to a Track A service a one-liner

### Track D — Data platform ⬜

- Lake: `aws/data-lake` (medallion S3 layout + Glue Catalog + Athena workgroup + Lake
  Formation) · `gcp/data-lake` (GCS + BigQuery datasets + Dataplex)
- ETL: `aws/glue-job`, `aws/step-functions-pipeline`, `gcp/dataflow-job`, `gcp/composer`
- Streaming: `aws/kinesis-stream` (Firehose exists), `aws/msk`, `gcp/dataflow-streaming`
- Warehouse: `gcp/bigquery-dataset`, `aws/redshift-serverless`
- `stacks/batch-etl-{aws,gcp}` — source → transform → lake → warehouse, scheduled or
  event-driven

### Track E — AI / ML & GPU ⬜

- Cloud-native: `gcp/gke-gpu-nodepool` (accelerator type/count, driver install, taints,
  spot, autoscaling), `aws/eks-gpu-nodegroup`, `aws/batch-gpu`, `aws/sagemaker-endpoint`,
  `gcp/vertex-endpoint`
- MLOps: model registry, artifact buckets, training-job orchestration, inference
  autoscaling (scale-to-zero on GPU)
- Managed wrappers (experimental, `restapi`-backed): `replicate/deployment` needs live-API
  verification to drop its banner; then `modal/app`, `fal/app`
- `stacks/ml-inference`

GPU modules are expensive to get wrong and hard to eyeball-review — an unpinned accelerator
type or a missing taint is a five-figure mistake. This track lands **after** the Phase 1
test harness, deliberately.

### Track F — Client & mobile delivery ⬜

The server side of Swift/iOS and Kotlin/Android apps, plus artifact distribution.

- `aws/cognito` / `gcp/identity-platform` — auth for mobile and SPA clients
- Push: SNS mobile push (APNs/FCM) / Firebase Cloud Messaging wiring
- `aws/static-site` (S3 + CloudFront + ACM) / `gcp/static-site` (GCS + Cloud CDN)
- Signed build-artifact buckets + CDN for app distribution, and the CI OIDC role to publish
- `stacks/mobile-backend` — API + auth + push + storage + CDN

### Track G — Cross-cutting quality ⬜

Runs continuously alongside the tracks, not after them.

- `examples/complete/` beside every `examples/basic/`
- Module maturity levels (experimental → beta → stable) with written criteria, surfaced in
  the generated catalog
- Docs site (terraform-docs → MkDocs/GitHub Pages) with the archetype table as the entry point
- `infracost` PR comments — cost delta as review context, which GPU and NAT gateways make
  matter a lot
- OPA/conftest policy pack for organizational rules beyond generic scanning
- Drift detection on `environments/**` via scheduled plan
- Terraform Registry publication

---

## Sequencing rationale

Phase 1 before everything is the load-bearing call. The library is about to grow ~5x; a
60-module repo with no tests, no interface contract, and no versioning is not a platform,
it is a maintenance burden with good intentions. The harness and the interface standard
are what let tracks A–F move fast without regressions.

Within the tracks, Track 0 and Track A come first because they unlock the largest share of
the goal: a network plus one solid container archetype deploys Go, Python, Node, Java,
Kotlin, Rust, C++, C#, and GraphQL services. Everything after that is breadth on a proven
foundation.
