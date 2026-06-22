# EXPERIMENTAL: wraps the Replicate REST API via the generic `restapi` provider.
# Replicate has no first-class Terraform provider, so we model a deployment as a
# REST object. The create endpoint infers the owner from the API token; read /
# update / destroy address the resource at /v1/deployments/{owner}/{name}.
#
# This module is intentionally excluded from CI validate (.validate-skip) until it
# has been verified end-to-end against the live API. Treat the path/method choices
# below as a starting point and confirm them against:
#   https://replicate.com/docs/reference/http#deployments.create
#   https://registry.terraform.io/providers/Mastercard/restapi/latest/docs

locals {
  deployment_body = {
    name          = var.name
    model         = var.model
    version       = var.version_id
    hardware      = var.hardware
    min_instances = var.min_instances
    max_instances = var.max_instances
  }
}

resource "restapi_object" "deployment" {
  # restapi substitutes {id} (the id_attribute value) into the *_path templates;
  # the owner segment is interpolated by Terraform from var.owner.
  id_attribute = "name"

  create_path  = "/v1/deployments"
  read_path    = "/v1/deployments/${var.owner}/{id}"
  update_path  = "/v1/deployments/${var.owner}/{id}"
  destroy_path = "/v1/deployments/${var.owner}/{id}"

  # Replicate updates deployments with PATCH, not the provider default (PUT).
  update_method = "PATCH"

  # `path` is required by the provider even when create_path is set.
  path = "/v1/deployments"

  data = jsonencode(local.deployment_body)
}
