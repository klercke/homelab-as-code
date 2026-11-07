# Platform

This module contains services that build on the substrate, but are still upstream of many services.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_kea"></a> [kea](#requirement\_kea) | 0.0.3 |
| <a name="requirement_powerdns"></a> [powerdns](#requirement\_powerdns) | ~> 1.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kea"></a> [kea](#provider\_kea) | 0.0.3 |
| <a name="provider_powerdns"></a> [powerdns](#provider\_powerdns) | 1.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_registry"></a> [registry](#module\_registry) | ../modules/registry | n/a |

## Resources

| Name | Type |
|------|------|
| [kea_dhcp4_reservation.this](https://registry.terraform.io/providers/wfdewith/kea/0.0.3/docs/resources/dhcp4_reservation) | resource |
| [powerdns_record.a](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.aaaa](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.ns_alias](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.ptr](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.ptr_v6](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.service](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.service_v6](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_zone.doh_canary](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/zone) | resource |
| [powerdns_zone.forward](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/zone) | resource |
| [powerdns_zone.public_internal](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/zone) | resource |
| [powerdns_zone.reverse](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/zone) | resource |
| [powerdns_zone.reverse_v6](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | The environment slug that this module operates under (prd, dev, lab). | `string` | `"prd"` | no |
| <a name="input_internal_proxy_host"></a> [internal\_proxy\_host](#input\_internal\_proxy\_host) | The host key for the server proxying internal services. | `string` | `"caddy01"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
