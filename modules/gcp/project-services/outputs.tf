output "enabled_services" {
  description = "The service hostnames enabled by this module."
  value       = sort([for s in google_project_service.this : s.service])
}

output "service_ids" {
  description = "Map of service hostname to its google_project_service resource id."
  value       = { for k, s in google_project_service.this : k => s.id }
}

output "project" {
  description = "Project the services were enabled on, as resolved by the provider."
  # services is validated non-empty, so index 0 always exists. one() is wrong here:
  # it errors on more than one element, and this map has one entry per service.
  value = values(google_project_service.this)[0].project
}
