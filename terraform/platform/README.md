# Platform

This module contains services that build on the substrate, but are still upstream of many services.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_netbox"></a> [netbox](#requirement\_netbox) | ~> 5.7 |
| <a name="requirement_powerdns"></a> [powerdns](#requirement\_powerdns) | ~> 1.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_netbox"></a> [netbox](#provider\_netbox) | 5.7.0 |
| <a name="provider_powerdns"></a> [powerdns](#provider\_powerdns) | 1.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_registry"></a> [registry](#module\_registry) | ../modules/registry | n/a |

## Resources

| Name | Type |
|------|------|
| [netbox_aggregate.private](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/aggregate) | resource |
| [netbox_cluster.protonet](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/cluster) | resource |
| [netbox_cluster_type.pve](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/cluster_type) | resource |
| [netbox_device_role.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_role) | resource |
| [netbox_interface.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/interface) | resource |
| [netbox_ip_address.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_address) | resource |
| [netbox_ip_range.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_range) | resource |
| [netbox_ipam_role.fns](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ipam_role) | resource |
| [netbox_mac_address.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/mac_address) | resource |
| [netbox_platform.rocky9](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/platform) | resource |
| [netbox_prefix.site](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/prefix) | resource |
| [netbox_prefix.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/prefix) | resource |
| [netbox_primary_ip.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/primary_ip) | resource |
| [netbox_rir.rfc1918](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/rir) | resource |
| [netbox_service.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/service) | resource |
| [netbox_site.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/site) | resource |
| [netbox_tag.crit](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/tag) | resource |
| [netbox_tag.hlac](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/tag) | resource |
| [netbox_virtual_disk.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/virtual_disk) | resource |
| [netbox_virtual_machine.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/virtual_machine) | resource |
| [netbox_virtual_machine_interface_primary_mac_address.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/virtual_machine_interface_primary_mac_address) | resource |
| [netbox_vlan.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/vlan) | resource |
| [netbox_vlan_group.site](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/vlan_group) | resource |
| [powerdns_record.a](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.ns_alias](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_record.ptr](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/record) | resource |
| [powerdns_zone.forward](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/zone) | resource |
| [powerdns_zone.reverse](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs/resources/zone) | resource |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
