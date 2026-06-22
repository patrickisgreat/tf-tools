# Resources and locals for this module. No `provider` blocks — the root config
# configures providers and passes them in.
#
# This scaffold uses a built-in `terraform_data` placeholder so it validates and
# lints cleanly out of the box (it references every declared variable). Replace it
# with the real resource(s) this module manages, e.g.:
#
#   resource "<provider>_<type>" "this" {
#     name = var.name
#     tags = var.tags
#   }

resource "terraform_data" "placeholder" {
  input = {
    name = var.name
    tags = var.tags
  }
}
