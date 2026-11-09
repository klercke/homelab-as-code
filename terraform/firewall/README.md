# Firewall

This module writes firewall aliases on fw01 from `registries/`: one `host_<name>` alias per VM and addressed device, and one `role_<role>` alias per role nesting them.
Rules stay hand-built in OPNsense and should reference the `role_` aliases, so a new node is covered as soon as it is in the registry.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_opnsense"></a> [opnsense](#requirement\_opnsense) | ~> 0.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_opnsense"></a> [opnsense](#provider\_opnsense) | 0.26.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_registry"></a> [registry](#module\_registry) | ../modules/registry | n/a |

## Resources

| Name | Type |
|------|------|
| [opnsense_firewall_alias.edge_scrape_ports](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_alias) | resource |
| [opnsense_firewall_alias.internal](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_alias) | resource |
| [opnsense_firewall_alias.node](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_alias) | resource |
| [opnsense_firewall_alias.public_dns](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_alias) | resource |
| [opnsense_firewall_alias.role](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_alias) | resource |
| [opnsense_firewall_alias.web_ports](https://registry.terraform.io/providers/browningluke/opnsense/latest/docs/resources/firewall_alias) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | The environment slug that this module operates under (prd, dev, lab). | `string` | `"prd"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
