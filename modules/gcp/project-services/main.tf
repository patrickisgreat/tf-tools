# Enables Google Cloud APIs on a project.
#
# Both destroy-time toggles default to false on purpose: a project is shared
# infrastructure, and disabling an API tears down every other workload in the
# project that depends on it. Terraform destroying one module's resources should
# not be able to break an unrelated service.

resource "google_project_service" "this" {
  for_each = toset(var.services)

  project = var.project
  service = each.value

  disable_on_destroy         = var.disable_on_destroy
  disable_dependent_services = var.disable_dependent_services
}
