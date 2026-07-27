locals {
  _base = "${path.module}/${var.registry_path}"

  _devices = yamldecode(file("${local._base}/devices.yaml"))

  sites        = yamldecode(file("${local._base}/sites.yaml")).sites
  vlans        = yamldecode(file("${local._base}/vlans.yaml")).vlans
  hosts        = yamldecode(file("${local._base}/hosts.yaml")).hosts
  regions      = try(yamldecode(file("${local._base}/sites.yaml")).regions, {})
  racks        = local._devices.racks
  locations    = local._devices.locations
  device_roles = local._devices.device_roles
  device_types = local._devices.device_types
  devices      = local._devices.devices

  host_site = {
    for name, h in local.hosts : name => local.vlans[h.vlan].site
  }

  host_ipv4 = {
    for name, h in local.hosts :
    name => cidrhost(local.vlans[h.vlan].prefix, h.host_octet)
  }

  host_cidr = {
    for name, h in local.hosts :
    name => "${local.host_ipv4[name]}/${split("/", local.vlans[h.vlan].prefix)[1]}"
  }

  host_vmid = {
    for name, h in local.hosts :
    name => local.vlans[h.vlan].id * 1000 + h.host_octet
  }

  macs = {
    for name, _ in local.hosts : name => upper(join(":", [
      "02",
      substr(sha256(name), 0, 2),
      substr(sha256(name), 2, 2),
      substr(sha256(name), 4, 2),
      substr(sha256(name), 6, 2),
      substr(sha256(name), 8, 2),
    ]))
  }

  reverse_zones = {
    for k, v in local.vlans :
    k => "${join(".", slice(reverse(split(".", split("/", v.prefix)[0])), 1, 4))}.in-addr.arpa."
  }

  host_records = {
    for name, h in local.hosts :
    name => {
      fqdn     = "${name}.${var.env}.${local.sites[local.host_site[name]].slug}.${var.domain}"
      ipv4     = local.host_ipv4[name]
      ptr_name = "${join(".", reverse(split(".", local.host_ipv4[name])))}.in-addr.arpa."
      rev_zone = local.reverse_zones[h.vlan]
    }
  }

  device_vlan = {
    for k, d in local.devices :
    k => one([
      for vk, v in local.vlans : vk
      if cidrhost(v.prefix, 0) == cidrhost("${d.mgmt_ip}/${split("/", v.prefix)[1]}", 0)
    ])
    if try(d.mgmt_ip, null) != null
  }

  device_mgmt_cidr = {
    for k, vk in local.device_vlan :
    k => "${local.devices[k].mgmt_ip}/${split("/", local.vlans[vk].prefix)[1]}"
  }

  # Devices with MACs specified get reservations
  reservations = {
    for k, d in local.devices : k => {
      hostname  = k
      mac       = lower(d.mac)
      ip        = d.mgmt_ip
      subnet_id = local.vlans[local.device_vlan[k]].id
    } if try(d.mac, null) != null
  }

  # Devices with a management address get DNS records, just like VMs
  device_records = {
    for k, vk in local.device_vlan :
    k => {
      fqdn     = "${k}.${var.env}.${local.sites[local.devices[k].site].slug}.${var.domain}"
      ipv4     = local.devices[k].mgmt_ip
      ptr_name = "${join(".", reverse(split(".", local.devices[k].mgmt_ip)))}.in-addr.arpa."
      rev_zone = local.reverse_zones[vk]
    }
  }
}
