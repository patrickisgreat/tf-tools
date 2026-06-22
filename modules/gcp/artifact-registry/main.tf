resource "google_artifact_registry_repository" "this" {
  repository_id = var.repository_id
  location      = var.location
  format        = var.format
  description   = var.description
  project       = var.project
  mode          = var.mode
  kms_key_name  = var.kms_key_name
  labels        = var.labels

  dynamic "docker_config" {
    for_each = var.format == "DOCKER" && var.immutable_tags != null ? [var.immutable_tags] : []
    content {
      immutable_tags = docker_config.value
    }
  }
}
