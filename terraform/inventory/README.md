# Inventory

This module records the lab in NetBox: sites, racks, devices, VMs, VLANs, prefixes, addresses and services, all derived from `registries/`.
Nothing else reads NetBox yet, so it applies last, after the role playbooks have NetBox running.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_netbox"></a> [netbox](#requirement\_netbox) | ~> 5.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_netbox"></a> [netbox](#provider\_netbox) | 5.8.0 |

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
| [netbox_device.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device) | resource |
| [netbox_device_bay.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_bay) | resource |
| [netbox_device_interface.mgmt](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_interface) | resource |
| [netbox_device_interface_primary_mac_address.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_interface_primary_mac_address) | resource |
| [netbox_device_primary_ip.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_primary_ip) | resource |
| [netbox_device_primary_ip.v6](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_primary_ip) | resource |
| [netbox_device_role.physical](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_role) | resource |
| [netbox_device_role.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_role) | resource |
| [netbox_device_type.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/device_type) | resource |
| [netbox_interface.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/interface) | resource |
| [netbox_ip_address.device_mgmt](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_address) | resource |
| [netbox_ip_address.device_mgmt_v6](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_address) | resource |
| [netbox_ip_address.device_secondary](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_address) | resource |
| [netbox_ip_address.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_address) | resource |
| [netbox_ip_address.v6](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_address) | resource |
| [netbox_ip_range.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ip_range) | resource |
| [netbox_ipam_role.fns](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/ipam_role) | resource |
| [netbox_location.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/location) | resource |
| [netbox_mac_address.device](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/mac_address) | resource |
| [netbox_mac_address.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/mac_address) | resource |
| [netbox_manufacturer.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/manufacturer) | resource |
| [netbox_platform.rocky9](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/platform) | resource |
| [netbox_prefix.site](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/prefix) | resource |
| [netbox_prefix.site_v6](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/prefix) | resource |
| [netbox_prefix.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/prefix) | resource |
| [netbox_prefix.v6](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/prefix) | resource |
| [netbox_primary_ip.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/primary_ip) | resource |
| [netbox_primary_ip.v6](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/primary_ip) | resource |
| [netbox_rack.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/rack) | resource |
| [netbox_region.l0](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/region) | resource |
| [netbox_region.l1](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/region) | resource |
| [netbox_region.l2](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/region) | resource |
| [netbox_rir.rfc1918](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/rir) | resource |
| [netbox_service.device](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/service) | resource |
| [netbox_service.vm](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/service) | resource |
| [netbox_site.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/site) | resource |
| [netbox_tag.crit](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/tag) | resource |
| [netbox_tag.hlac](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/tag) | resource |
| [netbox_virtual_disk.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/virtual_disk) | resource |
| [netbox_virtual_machine.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/virtual_machine) | resource |
| [netbox_virtual_machine_interface_primary_mac_address.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/virtual_machine_interface_primary_mac_address) | resource |
| [netbox_vlan.this](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/vlan) | resource |
| [netbox_vlan_group.site](https://registry.terraform.io/providers/e-breuninger/netbox/latest/docs/resources/vlan_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | The environment slug that this module operates under (prd, dev, lab). | `string` | `"prd"` | no |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | Per-site location information. Supplied via SOPS. | <pre>map(object({<br/>    latitude         = optional(number)<br/>    longitude        = optional(number)<br/>    physical_address = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
