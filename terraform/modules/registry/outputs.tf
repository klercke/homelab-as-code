output "sites" {
  description = "Raw sites registry, keyed by site name."
  value       = local.sites
}

output "vlans" {
  description = "Raw VLAN registry, keyed by VLAN name."
  value       = local.vlans
}

output "hosts" {
  description = "Raw host registry, keyed by hostname. Filter by layer at the call site."
  value       = local.hosts
}

output "host_site" {
  description = "Hostname -> site key, resolved through the host's VLAN."
  value       = local.host_site
}

output "host_ipv4" {
  description = "Hostname -> bare IPv4 address."
  value       = local.host_ipv4
}

output "host_cidr" {
  description = "Hostname -> IPv4 address with prefix length."
  value       = local.host_cidr
}

output "host_vmid" {
  description = "Hostname -> Proxmox VMID."
  value       = local.host_vmid
}

output "macs" {
  description = "Hostname -> deterministic locally-administered MAC."
  value       = local.macs
}

output "reverse_zones" {
  description = "VLAN key -> in-addr.arpa zone name, with trailing dot."
  value       = local.reverse_zones
}

output "host_records" {
  description = "Hostname -> { fqdn, ipv4, ptr_name, rev_zone } for DNS and documentation."
  value       = local.host_records
}

output "racks" { value = local.racks }
output "locations" { value = local.locations }
output "regions" { value = local.regions }
output "device_roles" { value = local.device_roles }
output "device_types" { value = local.device_types }
output "devices" { value = local.devices }

output "device_mgmt_cidr" {
  description = "Device name -> management IP with prefix length, resolved against the VLAN registry."
  value       = local.device_mgmt_cidr
}

output "device_vlan" {
  description = "Device name -> VLAN key containing its management address."
  value       = local.device_vlan
}

output "reservations" {
  description = "Device name -> Kea DHCP reservation. Only devices with a MAC."
  value       = local.reservations
}

output "device_records" {
  description = "Device name -> { fqdn, ipv4, ptr_name, rev_zone }."
  value       = local.device_records
}

output "role_services" {
  description = "Role key -> list of listening services."
  value       = local.role_services
}

output "public_services" {
  description = "User-facing name -> backend host and port, for the reverse proxy."
  value       = local.public_services
}

output "vm_services" {
  description = "Flattened services for virtual machines, keyed target/name/protocol."
  value       = local.vm_services
}

output "device_services" {
  description = "Flattened services for physical devices, keyed target/name/protocol."
  value       = local.device_services
}
