locals {
  # Each rule is encoded to JSON independently. Encoding the rules together (in one
  # list/concat) would make Terraform unify their object types and inject a null
  # "countUnit" into the imageCountMoreThan rule, which ECR's validator rejects.

  # Expire untagged images after N days (rulePriority 1).
  untagged_rule_json = var.expire_untagged_after_days > 0 ? jsonencode({
    rulePriority = 1
    description  = "Expire untagged images older than ${var.expire_untagged_after_days} days"
    selection = {
      tagStatus   = "untagged"
      countType   = "sinceImagePushed"
      countUnit   = "days"
      countNumber = var.expire_untagged_after_days
    }
    action = { type = "expire" }
  }) : null

  # Keep only the most recent N images (rulePriority 2). A tagStatus="any" rule
  # must carry the highest rulePriority, so it sorts after the untagged rule.
  keep_last_rule_json = var.keep_last_n_images > 0 ? jsonencode({
    rulePriority = 2
    description  = "Keep only the last ${var.keep_last_n_images} images"
    selection = {
      tagStatus   = "any"
      countType   = "imageCountMoreThan"
      countNumber = var.keep_last_n_images
    }
    action = { type = "expire" }
  }) : null

  rule_jsons = [for r in [local.untagged_rule_json, local.keep_last_rule_json] : r if r != null]

  # Prefer an explicit policy; otherwise synthesize one from the helpers; if both
  # helpers are disabled, attach no lifecycle policy at all.
  effective_lifecycle_policy = (
    var.lifecycle_policy != null ? var.lifecycle_policy :
    length(local.rule_jsons) > 0 ? "{\"rules\": [${join(", ", local.rule_jsons)}]}" :
    null
  )
}

resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }

  tags = var.tags
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = local.effective_lifecycle_policy != null ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = local.effective_lifecycle_policy
}

resource "aws_ecr_repository_policy" "this" {
  count      = var.repository_policy != null ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy
}
