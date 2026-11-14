# Cloud hosts (registries/cloud.yaml).
# Addresses and sizes come from the provider via the hlac.json substrate
# generates, not from the registry.

resource "netbox_site" "cloud" {
  for_each = local.cloud_sites

  name   = "${title(each.value.provider)} ${each.value.region}"
  slug   = each.key
  status = "active"
}

resource "netbox_cluster_type" "cloud" {
  for_each = toset([for _, s in local.cloud_sites : s.provider])

  name = title(each.value)
}

resource "netbox_cluster" "cloud" {
  for_each = local.cloud_sites

  name            = each.key
  cluster_type_id = netbox_cluster_type.cloud[each.value.provider].id
  site_id         = netbox_site.cloud[each.key].id
}

resource "netbox_virtual_machine" "cloud" {
  for_each = local.cloud_hosts

  name         = each.key
  cluster_id   = netbox_cluster.cloud["${each.value.provider}-${each.value.region}"].id
  site_id      = netbox_site.cloud["${each.value.provider}-${each.value.region}"].id
  role_id      = netbox_device_role.this[each.value.role].id
  platform_id  = each.value.image == "linode/rocky9" ? netbox_platform.rocky9.id : null
  status       = "active"
  vcpus        = each.value.vcpus
  memory_mb    = each.value.memory_mb
  disk_size_mb = each.value.disk_mb
  description  = each.value.description
  tags         = [netbox_tag.hlac.name, netbox_tag.crit[tostring(each.value.crit)].name]

  lifecycle {
    # Same race as the Proxmox VMs: NetBox recalculates from virtual disks
    ignore_changes = [disk_size_mb]
  }
}

resource "netbox_virtual_disk" "cloud" {
  for_each = local.cloud_hosts

  virtual_machine_id = netbox_virtual_machine.cloud[each.key].id
  name               = "disk"
  size_mb            = each.value.disk_mb
}

resource "netbox_interface" "cloud" {
  for_each = local.cloud_hosts

  virtual_machine_id = netbox_virtual_machine.cloud[each.key].id
  name               = "eth0"
  enabled            = true
}

resource "netbox_ip_address" "cloud_v4" {
  for_each = local.cloud_hosts

  ip_address   = "${each.value.ipv4}/24"
  status       = "active"
  dns_name     = each.value.rdns
  interface_id = netbox_interface.cloud[each.key].id
  object_type  = "virtualization.vminterface"
  description  = "Assigned by ${title(each.value.provider)}"
  tags         = [netbox_tag.hlac.name]
}

resource "netbox_ip_address" "cloud_v6" {
  for_each = local.cloud_hosts

  ip_address   = "${each.value.ipv6}/64"
  status       = "active"
  dns_name     = each.value.rdns
  interface_id = netbox_interface.cloud[each.key].id
  object_type  = "virtualization.vminterface"
  description  = "SLAAC, assigned by ${title(each.value.provider)}"
  tags         = [netbox_tag.hlac.name]
}

resource "netbox_primary_ip" "cloud_v4" {
  for_each = local.cloud_hosts

  virtual_machine_id = netbox_virtual_machine.cloud[each.key].id
  ip_address_id      = netbox_ip_address.cloud_v4[each.key].id

  depends_on = [netbox_virtual_disk.cloud]
}

resource "netbox_primary_ip" "cloud_v6" {
  for_each = local.cloud_hosts

  virtual_machine_id = netbox_virtual_machine.cloud[each.key].id
  ip_address_id      = netbox_ip_address.cloud_v6[each.key].id
  ip_address_version = 6

  depends_on = [netbox_primary_ip.cloud_v4]
}

resource "netbox_service" "cloud" {
  for_each = {
    for k, s in module.registry.cloud_services : k => s
    if contains(keys(local.cloud_hosts), s.target)
  }

  name               = each.value.name
  virtual_machine_id = netbox_virtual_machine.cloud[each.value.target].id
  protocol           = each.value.protocol
  ports              = each.value.ports
  description        = try(each.value.description, null)
  tags               = [netbox_tag.hlac.name]
}
