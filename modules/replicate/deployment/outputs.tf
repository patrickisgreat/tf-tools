output "id" {
  description = "restapi object ID (the deployment name)."
  value       = restapi_object.deployment.id
}

output "name" {
  description = "Deployment name."
  value       = var.name
}

output "endpoint" {
  description = "Prediction endpoint for this deployment."
  value       = "https://api.replicate.com/v1/deployments/${var.owner}/${var.name}/predictions"
}

output "api_response" {
  description = "Raw JSON returned by the Replicate API for the created object."
  value       = restapi_object.deployment.api_response
}
