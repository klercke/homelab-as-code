resource "netbox_vlan" "this" {
  for_each = local.vlans
  name     = each.value.name
  vid      = each.value.id
  group_id = netbox_vlan_group.site[each.value.site].id
  status   = each.value.status
  role_id  = netbox_ipam_role.fns[each.value.fns].id

  lifecycle {
    ignore_changes = [site_id] # Inherited from VLAN Group
  }
}

resource "netbox_prefix" "this" {
  for_each = local.vlans
  prefix   = each.value.prefix
  status   = each.value.status
  vlan_id  = netbox_vlan.this[each.key].id
  site_id  = netbox_site.this[each.value.site].id
  role_id  = netbox_ipam_role.fns[each.value.fns].id
}

resource "netbox_tag" "hlac" {
  name        = "hlac"
  color_hex   = "607d8b" #607d8b
  description = "Managed by homelab-as-code"
}

resource "netbox_tag" "crit" {
  for_each = toset(["1", "2", "3", "4"])
  name     = "crit-${each.value}"
  # crit1 #e01b24
  # crit2 #ff7800
  # crit3 #f6d32d
  # crit4 #33d17a
  color_hex = { "1" = "e01b24", "2" = "ff7800", "3" = "f6d32d", "4" = "33d17a" }[each.value]
}

resource "netbox_cluster_type" "pve" {
  name = "Proxmox VE"
}

resource "netbox_cluster" "protonet" {
  name            = "protonet"
  cluster_type_id = netbox_cluster_type.pve.id
  site_id         = netbox_site.this["home"].id
}

resource "netbox_platform" "rocky9" {
  name = "Rocky Linux 9"
}

resource "netbox_device_role" "this" {
  for_each  = toset([for _, h in local.hosts : h.role])
  name      = each.value
  color_hex = lookup(local.role_colors, each.value, "9e9e9e")
  vm_role   = true
}

resource "netbox_virtual_machine" "this" {
  for_each = local.hosts

  name        = each.key
  cluster_id  = netbox_cluster.protonet.id
  role_id     = netbox_device_role.this[each.value.role].id
  platform_id = netbox_platform.rocky9.id
  site_id     = netbox_site.this[local.host_site[each.key]].id
  status      = "active"
  vcpus       = each.value.cores
  memory_mb   = each.value.memory
  description = each.value.description
  tags        = [netbox_tag.hlac.name, netbox_tag.crit[tostring(each.value.crit)].name]
}

resource "netbox_interface" "this" {
  for_each           = local.hosts
  virtual_machine_id = netbox_virtual_machine.this[each.key].id
  name               = "eth0"
  enabled            = true
}

resource "netbox_mac_address" "this" {
  for_each = local.hosts

  mac_address                  = module.registry.macs[each.key]
  virtual_machine_interface_id = netbox_interface.this[each.key].id
}

resource "netbox_virtual_machine_interface_primary_mac_address" "this" {
  for_each = local.hosts

  interface_id   = netbox_interface.this[each.key].id
  mac_address_id = netbox_mac_address.this[each.key].id
}

resource "netbox_ip_address" "this" {
  for_each = local.hosts

  ip_address   = "${local.host_records[each.key].ipv4}/${split("/", local.vlans[each.value.vlan].prefix)[1]}"
  status       = "active"
  dns_name     = trimsuffix(local.host_records[each.key].fqdn, ".")
  interface_id = netbox_interface.this[each.key].id
  object_type  = "virtualization.vminterface"
}

resource "netbox_primary_ip" "this" {
  for_each           = local.hosts
  virtual_machine_id = netbox_virtual_machine.this[each.key].id
  ip_address_id      = netbox_ip_address.this[each.key].id
}

resource "netbox_ip_range" "this" {
  for_each = local.ip_ranges

  start_address = "${each.value.start}/${split("/", module.registry.vlans[each.value.vlan].prefix)[1]}"
  end_address   = "${each.value.end}/${split("/", module.registry.vlans[each.value.vlan].prefix)[1]}"
  status        = "active"
  description   = each.value.desc
  tags          = [netbox_tag.hlac.name]

  mark_utilized = each.value.utilized
}

resource "netbox_rir" "rfc1918" {
  name       = "RFC 1918"
  is_private = true
}

resource "netbox_aggregate" "private" {
  prefix      = "10.0.0.0/8"
  rir_id      = netbox_rir.rfc1918.id
  description = "RFC 1918 private space"
}

resource "netbox_prefix" "site" {
  for_each = module.registry.sites

  prefix      = each.value.prefix
  status      = "container"
  site_id     = netbox_site.this[each.key].id
  description = "${each.value.name} site allocation"
  tags        = [netbox_tag.hlac.name]
}

resource "netbox_vlan_group" "site" {
  for_each = module.registry.sites

  name       = "${each.value.name} VLANs"
  slug       = "${each.value.slug}-vlans"
  scope_type = "dcim.site"
  scope_id   = netbox_site.this[each.key].id

  # Allow use of the full 802.1Q range
  vid_ranges = [[1, 4094]]
}

resource "netbox_service" "this" {
  for_each = local.services

  name               = each.value.name
  virtual_machine_id = netbox_virtual_machine.this[each.value.host].id
  protocol           = each.value.protocol
  ports              = each.value.ports
}

resource "netbox_virtual_disk" "this" {
  for_each = local.vdisks

  virtual_machine_id = netbox_virtual_machine.this[each.value.host].id
  name               = each.value.name
  size_mb            = each.value.size * 1024
}

resource "netbox_ipam_role" "fns" {
  for_each = local.vlans
  name     = each.value.name
  slug     = each.value.fns
}

resource "netbox_mac_address" "device" {
  for_each = local.reserved_devices

  mac_address         = upper(each.value.mac)
  device_interface_id = netbox_device_interface.mgmt[each.key].id
}

resource "netbox_device_interface_primary_mac_address" "this" {
  for_each = local.reserved_devices

  interface_id   = netbox_device_interface.mgmt[each.key].id
  mac_address_id = netbox_mac_address.device[each.key].id
}
