terraform {
  # Remote state in S3. Fill these in, or leave them out and pass via:
  #   terraform init -backend-config=backend.hcl
  #
  # Terraform 1.10+ / AWS provider can use native S3 state locking via
  # `use_lockfile = true` instead of a DynamoDB table — drop dynamodb_table and
  # add `use_lockfile = true` if you prefer that.
  backend "s3" {
    bucket         = "REPLACE_ME-tf-state"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_ME-tf-locks"
    encrypt        = true
  }
}
