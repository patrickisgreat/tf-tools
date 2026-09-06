# `gcp/project-services`

Enables Google Cloud service APIs on a project.

## Usage

```hcl
module "services" {
  source = "../../modules/gcp/project-services"

  project  = "threaditate-support"
  services = [
    "iam.googleapis.com",
    "gmail.googleapis.com",
  ]
}
```

See [`examples/basic`](examples/basic) for a runnable example.

## Destroy behaviour

Both destroy-time toggles default to `false`, which is the safe choice for shared
infrastructure: a project's APIs are used by every workload in it, so
`terraform destroy` on one module must not be able to disable an API another service
depends on. Opt in deliberately if you own the whole project and want a clean teardown.

Services are keyed by hostname, so adding or removing one does not re-index the others
in state.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 8.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_project_service.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_disable_dependent_services"></a> [disable\_dependent\_services](#input\_disable\_dependent\_services) | Also disable services that depend on these. Defaults to false; enabling it makes a destroy cascade across the project. | `bool` | `false` | no |
| <a name="input_disable_on_destroy"></a> [disable\_on\_destroy](#input\_disable\_on\_destroy) | Disable the API when this resource is destroyed. Defaults to false: disabling a project-wide API can break unrelated workloads. | `bool` | `false` | no |
| <a name="input_project"></a> [project](#input\_project) | GCP project ID. Defaults to the provider's project when null. | `string` | `null` | no |
| <a name="input_services"></a> [services](#input\_services) | Service APIs to enable, by hostname, e.g. ["gmail.googleapis.com"]. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_enabled_services"></a> [enabled\_services](#output\_enabled\_services) | The service hostnames enabled by this module. |
| <a name="output_project"></a> [project](#output\_project) | Project the services were enabled on, as resolved by the provider. |
| <a name="output_service_ids"></a> [service\_ids](#output\_service\_ids) | Map of service hostname to its google\_project\_service resource id. |
<!-- END_TF_DOCS -->
