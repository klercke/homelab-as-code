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
| <a name="input_allowed_classes"></a> [allowed\_classes](#input\_allowed\_classes) | Class digits a site may use. Anything else is rejected at plan time. | `list(number)` | <pre>[<br/>  1<br/>]</pre> | no |
| <a name="input_class_digits"></a> [class\_digits](#input\_class\_digits) | First octet of an RFC 1918 supernet -> the digit prepended to net\_id to form<br/>the 802.1Q VLAN ID. 10.x -> 1, 172.16.x -> 2, 192.168.x -> 3. | `map(number)` | <pre>{<br/>  "10": 1,<br/>  "172": 2,<br/>  "192": 3<br/>}</pre> | no |
| <a name="input_dhcp_v4_dynamic_range"></a> [dhcp\_v4\_dynamic\_range](#input\_dhcp\_v4\_dynamic\_range) | Default inclusive [first, last] host octets for the DHCP dynamic pool. | `list(number)` | <pre>[<br/>  100,<br/>  199<br/>]</pre> | no |
| <a name="input_dhcp_v4_reservation_range"></a> [dhcp\_v4\_reservation\_range](#input\_dhcp\_v4\_reservation\_range) | Default inclusive [first, last] host octets for DHCP reservations. | `list(number)` | <pre>[<br/>  200,<br/>  249<br/>]</pre> | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Internal DNS domain with trailing dot. | `string` | `"protonet.internal."` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment label for canonical name. | `string` | `"prd"` | no |
| <a name="input_gateway_host_octet"></a> [gateway\_host\_octet](#input\_gateway\_host\_octet) | Host octet of the default gateway within each VLAN prefix. | `number` | `1` | no |
| <a name="input_registry_path"></a> [registry\_path](#input\_registry\_path) | Path to the registries directory relative to this module. | `string` | `"../../../registries"` | no |
| <a name="input_site_prefix_v4_bits"></a> [site\_prefix\_v4\_bits](#input\_site\_prefix\_v4\_bits) | Prefix length every site supernet must carry. | `number` | `16` | no |
| <a name="input_site_prefix_v6_bits"></a> [site\_prefix\_v6\_bits](#input\_site\_prefix\_v6\_bits) | Prefix length every site IPv6 prefix must carry (the ISP delegation). | `number` | `56` | no |
| <a name="input_static_range"></a> [static\_range](#input\_static\_range) | Inclusive [first, last] host octets for statically addressed hosts. | `list(number)` | <pre>[<br/>  10,<br/>  49<br/>]</pre> | no |
| <a name="input_vlan_prefix_v4_bits"></a> [vlan\_prefix\_v4\_bits](#input\_vlan\_prefix\_v4\_bits) | Prefix length of each derived VLAN segment. | `number` | `24` | no |
| <a name="input_vlan_prefix_v6_bits"></a> [vlan\_prefix\_v6\_bits](#input\_vlan\_prefix\_v6\_bits) | Prefix length of each derived VLAN IPv6 segment. | `number` | `64` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_records_v4"></a> [backend\_records\_v4](#output\_backend\_records\_v4) | Host or device name -> { fqdn, ipv4, ptr\_name, rev\_zone }. Valid public\_service backends. |
| <a name="output_device_mgmt_cidr_v4"></a> [device\_mgmt\_cidr\_v4](#output\_device\_mgmt\_cidr\_v4) | Device name -> management IP with prefix length. |
| <a name="output_device_records_v4"></a> [device\_records\_v4](#output\_device\_records\_v4) | Device name -> { fqdn, ipv4, ptr\_name, rev\_zone }. |
| <a name="output_device_roles"></a> [device\_roles](#output\_device\_roles) | Raw device role registry, keyed by role slug. |
| <a name="output_device_services"></a> [device\_services](#output\_device\_services) | Flattened services for physical devices keyed target/name/protocol. |
| <a name="output_device_types"></a> [device\_types](#output\_device\_types) | Raw device type registry, keyed by type slug. |
| <a name="output_device_vlan"></a> [device\_vlan](#output\_device\_vlan) | Device name -> VLAN key containing its management address. |
| <a name="output_devices"></a> [devices](#output\_devices) | Raw device registry, keyed by device name. |
| <a name="output_host_cidr_v4"></a> [host\_cidr\_v4](#output\_host\_cidr\_v4) | Hostname -> IPv4 address with prefix length. |
| <a name="output_host_cidr_v6"></a> [host\_cidr\_v6](#output\_host\_cidr\_v6) | Hostname -> IPv6 address with prefix length. Only hosts with ipv6: true are present. |
| <a name="output_host_ipv4"></a> [host\_ipv4](#output\_host\_ipv4) | Hostname -> bare IPv4 address. |
| <a name="output_host_ipv6"></a> [host\_ipv6](#output\_host\_ipv6) | Hostname -> bare IPv6 address. Only hosts with ipv6: true are present. |
| <a name="output_host_records_v4"></a> [host\_records\_v4](#output\_host\_records\_v4) | Hostname -> { fqdn, ipv4, ptr\_name, rev\_zone }. |
| <a name="output_host_records_v6"></a> [host\_records\_v6](#output\_host\_records\_v6) | Hostname -> { fqdn, ipv6, ptr\_name, rev\_zone }. Only hosts with ipv6: true are present. |
| <a name="output_host_site"></a> [host\_site](#output\_host\_site) | Hostname -> site key. |
| <a name="output_host_token_v6"></a> [host\_token\_v6](#output\_host\_token\_v6) | Hostname -> SLAAC interface identifier token (::<host\_octet in hex>). Only hosts with ipv6: true are present. |
| <a name="output_host_vmid"></a> [host\_vmid](#output\_host\_vmid) | Hostname -> Proxmox VMID. |
| <a name="output_hosts"></a> [hosts](#output\_hosts) | Raw host registry, keyed by hostname. Filter by layer at the call site. |
| <a name="output_locations"></a> [locations](#output\_locations) | Raw location registry, keyed by location slug. |
| <a name="output_macs"></a> [macs](#output\_macs) | Hostname -> MAC address. |
| <a name="output_public_services"></a> [public\_services](#output\_public\_services) | User-facing name -> backend host and port for the reverse proxy. |
| <a name="output_racks"></a> [racks](#output\_racks) | Raw rack registry, keyed by rack name. |
| <a name="output_regions"></a> [regions](#output\_regions) | Raw regions registry, keyed by region slug. |
| <a name="output_reservations"></a> [reservations](#output\_reservations) | Device name -> Kea DHCPv4 reservation. Only contains devices with a specified MAC. |
| <a name="output_reverse_zones_v4"></a> [reverse\_zones\_v4](#output\_reverse\_zones\_v4) | VLAN key -> in-addr.arpa zone name. |
| <a name="output_reverse_zones_v6"></a> [reverse\_zones\_v6](#output\_reverse\_zones\_v6) | VLAN key -> ip6.arpa zone name. Only VLANs with an IPv6 prefix are present. |
| <a name="output_role_services"></a> [role\_services](#output\_role\_services) | Role key -> list of listening services. |
| <a name="output_site_index"></a> [site\_index](#output\_site\_index) | Site key -> index within the addressing plan. |
| <a name="output_sites"></a> [sites](#output\_sites) | Raw sites registry, keyed by site name. |
| <a name="output_vlan_dhcp_v4"></a> [vlan\_dhcp\_v4](#output\_vlan\_dhcp\_v4) | VLAN key -> DHCPv4 pool boundary addresses. Only DHCPv4-enabled VLANs are present. |
| <a name="output_vlan_gateway_v4"></a> [vlan\_gateway\_v4](#output\_vlan\_gateway\_v4) | VLAN key -> IPv4 default gateway address. |
| <a name="output_vlan_id"></a> [vlan\_id](#output\_vlan\_id) | VLAN key -> 802.1Q ID. |
| <a name="output_vlan_prefix_v4"></a> [vlan\_prefix\_v4](#output\_vlan\_prefix\_v4) | VLAN key -> IPv4 prefix in CIDR. |
| <a name="output_vlan_prefix_v6"></a> [vlan\_prefix\_v6](#output\_vlan\_prefix\_v6) | VLAN key -> IPv6 prefix in CIDR. Only derived (net\_id) VLANs are present. |
| <a name="output_vlans"></a> [vlans](#output\_vlans) | Raw VLAN registry, keyed by VLAN name. Derived values live in the vlan\_* outputs. |
| <a name="output_vm_services"></a> [vm\_services](#output\_vm\_services) | Flattened services for virtual machines keyed target/name/protocol. |
<!-- END_TF_DOCS -->
