# == Raw Registry Passthroughs ==

output "sites" {
  description = "Raw sites registry, keyed by site name."
  value       = local.sites
}

output "regions" {
  description = "Raw regions registry, keyed by region slug."
  value       = local.regions
}

output "site_index" {
  description = "Site key -> index within the addressing plan."
  value       = local.site_index
}

output "vlans" {
  description = "Raw VLAN registry, keyed by VLAN name. Derived values live in the vlan_* outputs."
  value       = local.vlans
}

output "hosts" {
  description = "Raw host registry, keyed by hostname. Filter by layer at the call site."
  value       = local.hosts
}

output "racks" {
  description = "Raw rack registry, keyed by rack name."
  value       = local.racks
}

output "locations" {
  description = "Raw location registry, keyed by location slug."
  value       = local.locations
}

output "device_roles" {
  description = "Raw device role registry, keyed by role slug."
  value       = local.device_roles
}

output "device_types" {
  description = "Raw device type registry, keyed by type slug."
  value       = local.device_types
}

output "devices" {
  description = "Raw device registry, keyed by device name."
  value       = local.devices
}

# == VLANs ==

output "vlan_id" {
  description = "VLAN key -> 802.1Q ID."
  value       = local.vlan_id
}

output "vlan_prefix_v4" {
  description = "VLAN key -> IPv4 prefix in CIDR."
  value       = local.vlan_prefix_v4
}

output "vlan_prefix_v6" {
  description = "VLAN key -> IPv6 prefix in CIDR. Only derived (net_id) VLANs are present."
  value       = local.vlan_prefix_v6
}

output "vlan_gateway_v4" {
  description = "VLAN key -> IPv4 default gateway address."
  value       = local.vlan_gateway_v4
}

output "vlan_dhcp_v4" {
  description = "VLAN key -> DHCPv4 pool boundary addresses. Only DHCPv4-enabled VLANs are present."
  value       = local.vlan_dhcp_v4
}

# == Hosts ==

output "host_site" {
  description = "Hostname -> site key."
  value       = local.host_site
}

output "host_ipv4" {
  description = "Hostname -> bare IPv4 address."
  value       = local.host_ipv4
}

output "host_cidr_v4" {
  description = "Hostname -> IPv4 address with prefix length."
  value       = local.host_cidr_v4
}

output "host_ipv6" {
  description = "Hostname -> bare IPv6 address. Only hosts with ipv6: true are present."
  value       = local.host_ipv6
}

output "host_cidr_v6" {
  description = "Hostname -> IPv6 address with prefix length. Only hosts with ipv6: true are present."
  value       = local.host_cidr_v6
}

output "host_token_v6" {
  description = "Hostname -> SLAAC interface identifier token (::<host_octet in hex>). Only hosts with ipv6: true are present."
  value       = local.host_token_v6
}

output "host_vmid" {
  description = "Hostname -> Proxmox VMID."
  value       = local.host_vmid
}

output "macs" {
  description = "Hostname -> MAC address."
  value       = local.macs
}

# == DNS ==

output "reverse_zones_v4" {
  description = "VLAN key -> in-addr.arpa zone name."
  value       = local.reverse_zones_v4
}

output "reverse_zones_v6" {
  description = "VLAN key -> ip6.arpa zone name. Only VLANs with an IPv6 prefix are present."
  value       = local.reverse_zones_v6
}

output "host_records_v6" {
  description = "Hostname -> { fqdn, ipv6, ptr_name, rev_zone }. Only hosts with ipv6: true are present."
  value       = local.host_records_v6
}

output "host_records_v4" {
  description = "Hostname -> { fqdn, ipv4, ptr_name, rev_zone }."
  value       = local.host_records_v4
}

output "device_records_v4" {
  description = "Device name -> { fqdn, ipv4, ptr_name, rev_zone }."
  value       = local.device_records_v4
}

# == Devices ==

output "device_vlan" {
  description = "Device name -> VLAN key containing its management address."
  value       = local.device_vlan
}

output "device_mgmt_cidr_v4" {
  description = "Device name -> management IP with prefix length."
  value       = local.device_mgmt_cidr_v4
}

output "device_ipv6" {
  description = "Device name -> bare management IPv6 address. Only devices with mgmt_iid_v6 are present."
  value       = local.device_ipv6
}

output "device_mgmt_cidr_v6" {
  description = "Device name -> management IPv6 address with prefix length. Only devices with mgmt_iid_v6 are present."
  value       = local.device_mgmt_cidr_v6
}

output "device_records_v6" {
  description = "Device name -> { fqdn, ipv6, ptr_name, rev_zone }. Only devices with mgmt_iid_v6 are present."
  value       = local.device_records_v6
}

output "reservations" {
  description = "Device name -> Kea DHCPv4 reservation. Only contains devices with a specified MAC."
  value       = local.reservations
}

# == Services ==

output "host_services" {
  description = "Services on every host in hosts.yaml. Already folded into vm_services."
  value       = local.host_services
}

output "role_services" {
  description = "Role key -> list of listening services."
  value       = local.role_services
}

output "public_services" {
  description = "User-facing name -> backend host and port for the reverse proxy."
  value       = local.public_services
}

output "vm_services" {
  description = "Flattened services for virtual machines keyed target/name/protocol."
  value       = local.vm_services
}

output "device_services" {
  description = "Flattened services for physical devices keyed target/name/protocol."
  value       = local.device_services
}

output "backend_records_v4" {
  description = "Host or device name -> { fqdn, ipv4, ptr_name, rev_zone }. Valid public_service backends."
  value       = local.backend_records_v4
}
