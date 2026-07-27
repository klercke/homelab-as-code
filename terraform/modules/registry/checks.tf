check "vlan_references_resolve" {
  assert {
    condition = alltrue([
      for name, h in local.hosts : contains(keys(local.vlans), h.vlan)
    ])
    error_message = "A host in hosts.yaml references a vlan key that does not exist in vlans.yaml."
  }
}

check "site_references_resolve" {
  assert {
    condition = alltrue([
      for name, v in local.vlans : contains(keys(local.sites), v.site)
    ])
    error_message = "A VLAN in vlans.yaml references a site key that does not exist in sites.yaml."
  }
}

check "unique_octets_per_vlan" {
  assert {
    condition = length(local.hosts) == length(distinct([
      for name, h in local.hosts : "${h.vlan}/${h.host_octet}"
    ]))
    error_message = "Duplicate host_octet within a VLAN in hosts.yaml: two hosts would share an IP, VMID, and DHCP reservation."
  }
}

check "octets_in_static_range" {
  assert {
    condition = alltrue([
      for name, h in local.hosts : h.host_octet >= 10 && h.host_octet <= 49
    ])
    error_message = "A host_octet falls outside the static infrastructure range (.10-.49)."
  }
}

check "dhcp_pools_within_prefix" {
  assert {
    condition = alltrue(flatten([
      for name, v in local.vlans : [
        for ip in [
          v.dhcp.dynamic_start, v.dhcp.dynamic_end,
          v.dhcp.reservation_start, v.dhcp.reservation_end,
        ] : cidrhost(v.prefix, 0) == cidrhost("${ip}/${split("/", v.prefix)[1]}", 0)
      ] if try(v.dhcp.enabled, false)
    ]))
    error_message = "A DHCP pool boundary in vlans.yaml falls outside its own prefix."
  }
}

check "dhcp_pools_above_static_range" {
  assert {
    condition = alltrue(flatten([
      for name, v in local.vlans : [
        for ip in [v.dhcp.dynamic_start, v.dhcp.reservation_start] :
        tonumber(split(".", ip)[3]) >= 50
      ] if try(v.dhcp.enabled, false)
    ]))
    error_message = "A DHCP pool starts at or below .49, colliding with the static infrastructure range."
  }
}

check "dhcp_dynamic_below_reservations" {
  assert {
    condition = alltrue([
      for name, v in local.vlans :
      tonumber(split(".", v.dhcp.dynamic_end)[3]) < tonumber(split(".", v.dhcp.reservation_start)[3])
      if try(v.dhcp.enabled, false)
    ])
    error_message = "A dynamic pool overlaps its reservation range in vlans.yaml."
  }
}

check "no_name_collisions" {
  assert {
    condition     = length(setintersection(keys(local.hosts), keys(local.devices))) == 0
    error_message = "A name appears in both hosts.yaml and devices.yaml; their DNS records would collide."
  }
}
