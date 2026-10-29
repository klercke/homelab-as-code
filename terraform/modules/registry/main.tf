locals {
  _base     = "${path.module}/${var.registry_path}"
  _devices  = yamldecode(file("${local._base}/devices.yaml"))
  _services = yamldecode(file("${local._base}/services.yaml"))
  _sites    = yamldecode(file("${local._base}/sites.yaml"))

  sites   = local._sites.sites
  regions = try(local._sites.regions, {})
  # Second octet of the site's /16
  site_index = {
    for sk, s in local.sites : sk => tonumber(split(".", split("/", s.prefix_v4)[0])[1])
  }
  vlans = yamldecode(file("${local._base}/vlans.yaml")).vlans
  hosts = yamldecode(file("${local._base}/hosts.yaml")).hosts

  racks        = local._devices.racks
  locations    = local._devices.locations
  device_roles = local._devices.device_roles
  device_types = local._devices.device_types
  devices      = local._devices.devices

  role_services   = local._services.role_services
  public_services = local._services.public_services

  # == Site plan ==

  _site_first_octet = {
    for sk, s in local.sites : sk => split(".", split("/", s.prefix_v4)[0])[0]
  }

  # Class digit, prepended to net_id to form the 802.1Q tag.
  site_class = {
    for sk, o in local._site_first_octet : sk => lookup(var.class_digits, o, null)
  }

  # == VLANs ==

  # A VLAN will have its prefixes and VLAN tag derived from net_id and the site
  # plan, unless prefix_v4 and vlan_id are specified, in which case IPv6 is
  # disabled and no values are derived automatically.

  vlan_is_derived = {
    for k, v in local.vlans : k => try(v.prefix_v4, null) == null
  }

  vlan_id = { for k, v in local.vlans : k => (
    local.vlan_is_derived[k]
    ? tonumber("${local.site_class[v.site]}${v.net_id}")
    : v.vlan_id
  ) }

  vlan_prefix_v4 = { for k, v in local.vlans : k => (
    local.vlan_is_derived[k]
    ? cidrsubnet(
      local.sites[v.site].prefix_v4,
      var.vlan_prefix_v4_bits - var.site_prefix_v4_bits,
      v.net_id
    )
    : v.prefix_v4
  ) }

  # Subnet ID is net_id taken as a plain number, so net_id 20 is :14 within the
  # site prefix. Override VLANs get no IPv6 and are absent from this map.
  vlan_prefix_v6 = {
    for k, v in local.vlans : k => cidrsubnet(
      local.sites[v.site].prefix_v6,
      var.vlan_prefix_v6_bits - var.site_prefix_v6_bits,
      v.net_id
    ) if local.vlan_is_derived[k]
  }

  vlan_gateway_v4 = {
    for k, _ in local.vlans : k => cidrhost(local.vlan_prefix_v4[k], var.gateway_host_octet)
  }

  # Will only get generated for DHCPv4-enabled VLANs
  vlan_dhcp_v4_octets = {
    for k, v in local.vlans : k => {
      dynamic_start     = try(v.dhcp_v4.dynamic_start, var.dhcp_v4_dynamic_range[0])
      dynamic_end       = try(v.dhcp_v4.dynamic_end, var.dhcp_v4_dynamic_range[1])
      reservation_start = try(v.dhcp_v4.reservation_start, var.dhcp_v4_reservation_range[0])
      reservation_end   = try(v.dhcp_v4.reservation_end, var.dhcp_v4_reservation_range[1])
    } if v.dhcp_v4.enabled
  }

  vlan_dhcp_v4 = {
    for k, octets in local.vlan_dhcp_v4_octets : k => {
      for label, octet in octets : label => cidrhost(local.vlan_prefix_v4[k], octet)
    }
  }


  # == Hosts ==

  host_site = {
    for name, h in local.hosts : name => local.vlans[h.vlan].site
  }

  host_ipv4 = {
    for name, h in local.hosts :
    name => cidrhost(local.vlan_prefix_v4[h.vlan], h.host_octet)
  }

  host_cidr_v4 = {
    for name, h in local.hosts :
    name => "${local.host_ipv4[name]}/${split("/", local.vlan_prefix_v4[h.vlan])[1]}"
  }

  # IPv6 is opt-in per host (ipv6: true) and only on VLANs with an IPv6 prefix.
  # Hosts get their address by SLAAC with a fixed interface identifier (token)
  # equal to host_octet, so the address is predictable without being static.
  _host_v6 = {
    for name, h in local.hosts : name => h
    if try(h.ipv6, false) && contains(keys(local.vlan_prefix_v6), h.vlan)
  }

  host_ipv6 = {
    for name, h in local._host_v6 :
    name => cidrhost(local.vlan_prefix_v6[h.vlan], h.host_octet)
  }

  host_cidr_v6 = {
    for name, h in local._host_v6 :
    name => "${local.host_ipv6[name]}/${var.vlan_prefix_v6_bits}"
  }

  host_token_v6 = {
    for name, h in local._host_v6 : name => format("::%x", h.host_octet)
  }

  host_vmid = {
    for name, h in local.hosts :
    name => local.vlan_id[h.vlan] * 1000 + h.host_octet
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

  # == DNS ==

  reverse_zones_v4 = {
    for k, _ in local.vlans :
    k => format("%s.in-addr.arpa.", join(".", slice(reverse(split(".",
      split("/", local.vlan_prefix_v4[k])[0]
    )), 1, 4)))
  }

  # Fully expanded 32-nibble forms of IPv6 addresses and VLAN prefixes, needed
  # for ip6.arpa names. Splits on "::", pads the missing groups with zeros, then
  # zero-pads every group to four hex digits.
  _v6_in = merge(
    { for k, a in local.host_ipv6 : "host/${k}" => a },
    { for k, p in local.vlan_prefix_v6 : "vlan/${k}" => split("/", p)[0] },
  )
  _v6_halves = { for k, a in local._v6_in : k => split("::", a) }
  _v6_left = {
    for k, h in local._v6_halves : k => h[0] == "" ? [] : split(":", h[0])
  }
  _v6_right = {
    for k, h in local._v6_halves : k => length(h) > 1 && h[1] != "" ? split(":", h[1]) : []
  }
  _v6_full = {
    for k, _ in local._v6_in : k => join("", [
      for g in concat(
        local._v6_left[k],
        [for i in range(8 - length(local._v6_left[k]) - length(local._v6_right[k])) : "0"],
        local._v6_right[k],
      ) : format("%04x", parseint(g, 16))
    ])
  }

  reverse_zones_v6 = {
    for k, _ in local.vlan_prefix_v6 : k => format("%s.ip6.arpa.", join(".", reverse(
      regexall(".", substr(local._v6_full["vlan/${k}"], 0, var.vlan_prefix_v6_bits / 4))
    )))
  }

  host_records_v6 = {
    for name, h in local._host_v6 : name => {
      fqdn     = "${name}.${var.env}.${local.sites[local.host_site[name]].slug}.${var.domain}"
      ipv6     = local.host_ipv6[name]
      ptr_name = format("%s.ip6.arpa.", join(".", reverse(regexall(".", local._v6_full["host/${name}"]))))
      rev_zone = local.reverse_zones_v6[h.vlan]
    }
  }

  host_records_v4 = {
    for name, h in local.hosts : name => {
      fqdn     = "${name}.${var.env}.${local.sites[local.host_site[name]].slug}.${var.domain}"
      ipv4     = local.host_ipv4[name]
      ptr_name = "${join(".", reverse(split(".", local.host_ipv4[name])))}.in-addr.arpa."
      rev_zone = local.reverse_zones_v4[h.vlan]
    }
  }

  # == Devices ==

  device_vlan = {
    for k, d in local.devices : k => one([
      for vk, v in local.vlans : vk
      if v.site == d.site && cidrhost(local.vlan_prefix_v4[vk], 0) == cidrhost(
        "${d.mgmt_ip}/${split("/", local.vlan_prefix_v4[vk])[1]}", 0
      )
    ]) if try(d.mgmt_ip, null) != null
  }

  device_mgmt_cidr_v4 = {
    for k, vk in local.device_vlan :
    k => "${local.devices[k].mgmt_ip}/${split("/", local.vlan_prefix_v4[vk])[1]}"
  }

  # Devices with MACs specified get reservations
  reservations = {
    for k, d in local.devices : k => {
      hostname  = k
      mac       = lower(d.mac)
      ip        = d.mgmt_ip
      subnet_id = local.vlan_id[local.device_vlan[k]]
    } if try(d.mac, null) != null
  }

  # Devices with a management address get DNS records
  device_records_v4 = {
    for k, vk in local.device_vlan : k => {
      fqdn     = "${k}.${var.env}.${local.sites[local.devices[k].site].slug}.${var.domain}"
      ipv4     = local.devices[k].mgmt_ip
      ptr_name = "${join(".", reverse(split(".", local.devices[k].mgmt_ip)))}.in-addr.arpa."
      rev_zone = local.reverse_zones_v4[vk]
    }
  }

  # == Services ==

  # Keyed by target/name/protocol because DNS exists on both TCP and UDP, so
  # the protocol has to be part of the key to avoid collisions
  vm_services = merge(concat([
    for hk, h in local.hosts : {
      for s in try(local.role_services[h.role], []) :
      "${hk}/${s.name}/${s.protocol}" => merge(s, { target = hk })
    }
  ], [{}])...)

  device_services = merge(concat([
    for dk, d in local.devices : {
      for s in try(local.role_services[d.role], []) :
      "${dk}/${s.name}/${s.protocol}" => merge(s, { target = dk })
    }
  ], [{}])...)

  # Anything that a public_service can point at
  backend_records_v4 = merge(
    local.host_records_v4,
    local.device_records_v4,
  )

  unresolved_backends = [
    for k, s in local.public_services : "${k} -> ${s.backend}"
    if !contains(keys(local.backend_records_v4), s.backend)
  ]
}
