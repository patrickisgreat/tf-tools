resource "google_storage_bucket" "this" {
  name                        = var.name
  project                     = var.project
  location                    = var.location
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access
  public_access_prevention    = var.public_access_prevention
  force_destroy               = var.force_destroy
  labels                      = var.labels

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "encryption" {
    for_each = var.kms_key_name != null ? [var.kms_key_name] : []
    content {
      default_kms_key_name = encryption.value
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lifecycle_rule.value.action.storage_class
      }
      condition {
        age                   = lifecycle_rule.value.condition.age
        created_before        = lifecycle_rule.value.condition.created_before
        with_state            = lifecycle_rule.value.condition.with_state
        matches_storage_class = lifecycle_rule.value.condition.matches_storage_class
        num_newer_versions    = lifecycle_rule.value.condition.num_newer_versions
      }
    }
  }
}
