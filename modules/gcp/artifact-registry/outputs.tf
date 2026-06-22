output "id" {
  description = "Fully-qualified repository id."
  value       = google_artifact_registry_repository.this.id
}

output "name" {
  description = "Repository name (the repository_id)."
  value       = google_artifact_registry_repository.this.name
}

output "repository_url" {
  description = "Host path to push/pull artifacts (Docker format): <location>-docker.pkg.dev/<project>/<repository_id>."
  value = (
    var.format == "DOCKER"
    ? "${var.location}-docker.pkg.dev/${google_artifact_registry_repository.this.project}/${var.repository_id}"
    : null
  )
}
