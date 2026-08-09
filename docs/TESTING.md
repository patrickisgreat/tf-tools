# Testing modules

`terraform validate` checks that HCL parses and references resolve. It does not check that
a module produces the resources it claims, that its "secure defaults" are actually secure,
or that a `validation` block rejects what it is supposed to reject. This is what closes
that gap.

We use **native `terraform test`** (Terraform 1.6+) with **`mock_provider`** (1.7+). Every
suite plans the module against a mocked provider, so it needs **no cloud credentials and
creates no infrastructure** — the whole suite runs on every PR.

```bash
make test                                  # every module suite
cd modules/aws/ecr && terraform test       # one module
terraform test -filter=tests/defaults.tftest.hcl -verbose
```

## Layout

Each module owns `tests/*.tftest.hcl`. `modules/_template/tests/defaults.tftest.hcl` is the
starter, so a module scaffolded with `make new-module` is born tested.

```hcl
mock_provider "aws" {}

variables {
  name = "team/service"        # module-wide defaults for every run block
}

run "secure_defaults" {
  command = plan

  assert {
    condition     = aws_ecr_repository.this.image_tag_mutability == "IMMUTABLE"
    error_message = "Image tags must be immutable by default — mutable tags let a pushed digest change under a running deployment."
  }
}
```

## What to assert

Four categories, in rough order of value:

1. **Secure defaults.** Assert the *default* configuration is the safe one — encryption on,
   public access blocked, immutable tags, UBLA enforced, `force_destroy` off. Our
   conventions claim secure-by-default; these assertions are what make the claim true
   rather than aspirational.
2. **Conditional wiring.** Optional resources appear and disappear with their toggle
   (`length(aws_s3_bucket_policy.this) == 0` until a policy is supplied).
3. **Pass-through.** A supplied value reaches the resource unchanged.
4. **Input validation.** One `run` block per `validation` block, using `expect_failures`.

Write `error_message` for a reader who just broke the assertion and does not know why the
default was chosen. "Must be IMMUTABLE" is useless; "mutable tags let a pushed digest change
under a running deployment" tells them what they are about to break.

## Known limits

These are properties of Terraform and the providers, not gaps we intend to close. Work
within them rather than fighting them.

**Optional+Computed attributes are unknown at plan time.** If a provider marks an attribute
`Computed`, the plan reports it as unknown whenever the module leaves it null — so
`condition = resource.this.some_attr == null` fails with *"Unknown condition value"* rather
than passing. You cannot assert that a module *omitted* something. Assert the positive path
instead (that a supplied value is wired through), and leave a comment noting the inverse is
untestable. `aws/sqs` and `aws/ecr` both carry one.

Sometimes the plan *succeeding at all* is the assertion. `aws/sqs`'s
`kms_encryption_plans_cleanly` exists because `sqs_managed_sse_enabled` and
`kms_master_key_id` are `ConflictsWith` in the provider — and that check fires on an
argument being *present* in config, so setting the first to `false` alongside a key still
errored out. The run block's real job is to fail loudly if that regresses.

**Set-typed nested blocks cannot be indexed.** Many nested blocks (`rule`,
`apply_server_side_encryption_by_default`, `action`, `condition`) are sets, not lists, so
`resource.this.rule[0]` errors with *"Cannot index a set value"*. Use `one()`:

```hcl
one(one(aws_s3_bucket_server_side_encryption_configuration.this.rule).apply_server_side_encryption_by_default).sse_algorithm
```

**`expect_failures` names the variable the `validation` block is declared on**, which is not
always the variable holding the bad value. `aws/sqs` validates the name-suffix rule on
`var.fifo_queue` (it needs both values), so the expectation is `[var.fifo_queue]` even
though `var.name` is what is wrong.

## Verify the test can fail

An assertion that cannot fail is worse than no assertion — it reads as coverage. When you
add one, break the module on purpose and confirm the suite goes red:

```bash
# flip a secure default in variables.tf, then:
terraform test        # must fail, and the message must explain what broke
git checkout variables.tf
```

This is how the `aws/sqs` KMS bug was found: the suite was written, run, and the module
failed to plan at all.
