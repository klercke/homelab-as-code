# Cloudflare

This module manages the public `ptxe.dev` zone from `registries/public_dns.yaml`.
The apex A record is left to OPNsense's dynamic DNS; everything else is here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.28 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 5.28.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_registry"></a> [registry](#module\_registry) | ../modules/registry | n/a |

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.edge_aaaa](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.exposed](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_edge_proxy_host"></a> [edge\_proxy\_host](#input\_edge\_proxy\_host) | The host key for the server that serves exposed names. | `string` | `"edge01"` | no |
| <a name="input_env"></a> [env](#input\_env) | The environment slug that this module operates under (prd, dev, lab). | `string` | `"prd"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
