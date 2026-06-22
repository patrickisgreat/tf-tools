terraform {
  # Root configs pin providers (and commit .terraform.lock.hcl) for reproducible
  # applies — unlike the modules, which use permissive constraints.
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}
