output "email" {
  description = "Email address of the service account (use as the member identity)."
  value       = google_service_account.this.email
}

output "id" {
  description = "Fully-qualified service account id."
  value       = google_service_account.this.id
}

output "name" {
  description = "Resource name (projects/<project>/serviceAccounts/<email>)."
  value       = google_service_account.this.name
}

output "unique_id" {
  description = "Numeric unique id of the service account."
  value       = google_service_account.this.unique_id
}

output "member" {
  description = "IAM member string for the service account (serviceAccount:<email>)."
  value       = "serviceAccount:${google_service_account.this.email}"
}

output "private_key" {
  description = "Base64 JSON private key, if create_key is true. Sensitive."
  value       = var.create_key ? google_service_account_key.this[0].private_key : null
  sensitive   = true
}
