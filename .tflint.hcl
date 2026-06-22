config {
  # Lint nested module directories too.
  call_module_type = "all"
}

# Core Terraform rules (bundled with tflint, no install needed).
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# Provider-specific rulesets are opt-in. Uncomment and pin a version to enable;
# `tflint --init` will download it. Keep the version current with the registry.
#
# plugin "aws" {
#   enabled = true
#   version = "0.37.0"
#   source  = "github.com/terraform-linters/tflint-ruleset-aws"
# }
#
# plugin "google" {
#   enabled = true
#   version = "0.31.0"
#   source  = "github.com/terraform-linters/tflint-ruleset-google"
# }
