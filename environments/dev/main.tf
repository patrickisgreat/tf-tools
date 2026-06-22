# Compose modules from the library here. This is the "set vars and go" layer:
# concrete values live in terraform.tfvars; the modules stay generic.

module "app_ecr" {
  source = "../../modules/aws/ecr"

  name                       = "${var.name_prefix}/app"
  keep_last_n_images         = 30
  expire_untagged_after_days = 14
}

# Add more modules as the environment grows, e.g.:
#
# module "events_topic" {
#   source = "../../modules/aws/sns"
#   name   = "${var.name_prefix}-events"
# }

output "app_repository_url" {
  description = "ECR repository URL for the app image."
  value       = module.app_ecr.repository_url
}
