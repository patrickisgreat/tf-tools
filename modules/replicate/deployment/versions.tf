terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # Generic REST CRUD provider used to drive the Replicate HTTP API.
    # Configure it in the root config with the Replicate base URI + auth header.
    restapi = {
      source  = "Mastercard/restapi"
      version = ">= 1.19.0"
    }
  }
}
