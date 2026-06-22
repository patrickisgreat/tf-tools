resource "google_service_account" "this" {
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
  project      = var.project
  disabled     = var.disabled
}

resource "google_project_iam_member" "this" {
  for_each = toset(var.project_roles)

  # Bind in the account's own project (var.project may be null and resolved by the provider).
  project = google_service_account.this.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}

resource "google_service_account_key" "this" {
  count              = var.create_key ? 1 : 0
  service_account_id = google_service_account.this.name
}
