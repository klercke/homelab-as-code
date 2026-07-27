# Registry

This module contains code to interface with the hlac registries.
This ensures that no other submodules disagree about any data derived from the registries.

## Terraform Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | Internal DNS domain, with trailing dot. | `string` | `"protonet.internal."` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment label for canonical names. Everything is prod right now. | `string` | `"prd"` | no |
| <a name="input_registry_path"></a> [registry\_path](#input\_registry\_path) | Path to the registries directory, relative to this module. | `string` | `"../../../registries"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_device_mgmt_cidr"></a> [device\_mgmt\_cidr](#output\_device\_mgmt\_cidr) | Device name -> management IP with prefix length, resolved against the VLAN registry. |
| <a name="output_device_records"></a> [device\_records](#output\_device\_records) | Device name -> { fqdn, ipv4, ptr\_name, rev\_zone }. |
| <a name="output_device_roles"></a> [device\_roles](#output\_device\_roles) | n/a |
| <a name="output_device_services"></a> [device\_services](#output\_device\_services) | Flattened services for physical devices, keyed target/name/protocol. |
| <a name="output_device_types"></a> [device\_types](#output\_device\_types) | n/a |
| <a name="output_device_vlan"></a> [device\_vlan](#output\_device\_vlan) | Device name -> VLAN key containing its management address. |
| <a name="output_devices"></a> [devices](#output\_devices) | n/a |
| <a name="output_host_cidr"></a> [host\_cidr](#output\_host\_cidr) | Hostname -> IPv4 address with prefix length. |
| <a name="output_host_ipv4"></a> [host\_ipv4](#output\_host\_ipv4) | Hostname -> bare IPv4 address. |
| <a name="output_host_records"></a> [host\_records](#output\_host\_records) | Hostname -> { fqdn, ipv4, ptr\_name, rev\_zone } for DNS and documentation. |
| <a name="output_host_site"></a> [host\_site](#output\_host\_site) | Hostname -> site key, resolved through the host's VLAN. |
| <a name="output_host_vmid"></a> [host\_vmid](#output\_host\_vmid) | Hostname -> Proxmox VMID. |
| <a name="output_hosts"></a> [hosts](#output\_hosts) | Raw host registry, keyed by hostname. Filter by layer at the call site. |
| <a name="output_locations"></a> [locations](#output\_locations) | n/a |
| <a name="output_macs"></a> [macs](#output\_macs) | Hostname -> deterministic locally-administered MAC. |
| <a name="output_public_services"></a> [public\_services](#output\_public\_services) | User-facing name -> backend host and port, for the reverse proxy. |
| <a name="output_racks"></a> [racks](#output\_racks) | n/a |
| <a name="output_regions"></a> [regions](#output\_regions) | n/a |
| <a name="output_reservations"></a> [reservations](#output\_reservations) | Device name -> Kea DHCP reservation. Only devices with a MAC. |
| <a name="output_reverse_zones"></a> [reverse\_zones](#output\_reverse\_zones) | VLAN key -> in-addr.arpa zone name, with trailing dot. |
| <a name="output_role_services"></a> [role\_services](#output\_role\_services) | Role key -> list of listening services. |
| <a name="output_sites"></a> [sites](#output\_sites) | Raw sites registry, keyed by site name. |
| <a name="output_vlans"></a> [vlans](#output\_vlans) | Raw VLAN registry, keyed by VLAN name. |
| <a name="output_vm_services"></a> [vm\_services](#output\_vm\_services) | Flattened services for virtual machines, keyed target/name/protocol. |
<!-- END_TF_DOCS -->
