# `terraform test` suite for this module. Runs against a mocked provider, so it
# needs no credentials and creates nothing. See docs/TESTING.md.
#
# Uncomment the mock_provider for whichever provider this module declares in
# versions.tf, then write assertions in these four categories. Delete the
# placeholder run block once real ones exist — an empty suite is worse than no
# suite, because it reads as coverage.
#
# mock_provider "aws" {}
# mock_provider "google" {}

variables {
  name = "example"
}

# 1. Secure defaults — assert the *default* configuration is the safe one.
#    This is the category that earns the suite its keep: conventions claim
#    secure-by-default, and this is what makes the claim testable.
run "secure_defaults" {
  command = plan

  assert {
    condition     = terraform_data.placeholder.input.name == "example"
    error_message = "Replace this with real assertions about the module's defaults."
  }
}

# 2. Conditional wiring — optional resources appear and disappear with their toggle.
#
# run "optional_resource_is_opt_in" {
#   command = plan
#   assert {
#     condition     = length(aws_something.this) == 0
#     error_message = "Nothing should be created until the feature is enabled."
#   }
# }

# 3. Pass-through — supplied values reach the resource unchanged.
#
# run "kms_key_is_wired" {
#   command   = plan
#   variables { kms_key_arn = "arn:aws:kms:us-east-1:111122223333:key/abc" }
#   assert {
#     condition     = aws_something.this.kms_key_arn == "arn:aws:kms:us-east-1:111122223333:key/abc"
#     error_message = "A supplied kms_key_arn must be used."
#   }
# }

# 4. Input validation — one run per `validation` block, using expect_failures.
#    The checkable object is the variable the validation block is *declared on*,
#    which is not always the variable whose value is wrong.
#
# run "rejects_bad_name" {
#   command         = plan
#   variables { name = "Not Valid" }
#   expect_failures = [var.name]
# }
