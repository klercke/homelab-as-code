check "vlan_references_resolve" {
  assert {
    condition = alltrue([
      for name, h in local.hosts : contains(keys(local.vlans), h.vlan)
    ])
    error_message = "A host in hosts.yaml references a vlan that does not exist in vlans.yaml."
  }
}

check "site_references_resolve" {
  assert {
    condition = alltrue([
      for name, v in local.vlans : contains(keys(local.sites), v.site)
    ])
    error_message = "A VLAN in vlans.yaml references a site that does not exist in sites.yaml."
  }
}

check "site_prefix_v4_shape" {
  assert {
    condition = alltrue([
      for sk, s in local.sites :
      tonumber(split("/", s.prefix_v4)[1]) == var.site_prefix_v4_bits &&
      local.site_class[sk] != null
    ])
    error_message = "A site prefix_v4 is the wrong length or starts with an invalid octet."
  }
}

check "site_prefix_v6_shape" {
  assert {
    condition = alltrue([
      for sk, s in local.sites :
      tonumber(split("/", s.prefix_v6)[1]) == var.site_prefix_v6_bits &&
      cidrhost(s.prefix_v6, 0) == split("/", s.prefix_v6)[0]
    ])
    error_message = "A site prefix_v6 is the wrong length, has host bits set, or is not in canonical lowercase form."
  }
}

check "site_class_allowed" {
  assert {
    condition = alltrue([
      for sk, c in local.site_class : contains(var.allowed_classes, c) if c != null
    ])
    error_message = "A site uses a class digit outside allowed_classes. Class B and C are reserved but not in use."
  }
}

check "vlan_shape" {
  assert {
    condition = alltrue([
      for k, v in local.vlans : (
        local.vlan_is_derived[k]
        ? try(v.net_id, null) != null && try(v.vlan_id, null) == null
        : try(v.vlan_id, null) != null && try(v.net_id, null) == null
      )
    ])
    error_message = "A VLAN must specify EITHER net_id OR prefix_v4 AND vlan_id, NOT both."
  }
}

check "net_id_in_range" {
  assert {
    condition = alltrue([
      for k, v in local.vlans :
      v.net_id >= 0 && v.net_id <= 255 if local.vlan_is_derived[k]
    ])
    error_message = "net_id must be 0-255."
  }
}

check "vlan_id_unique_per_site" {
  assert {
    condition = length(distinct([
      for k, v in local.vlans : "${v.site}/${local.vlan_id[k]}"
    ])) == length(local.vlans)
    error_message = "Two VLANs at the same site have the same 802.1Q VLAN ID."
  }
}

check "net_id_fits_v6_subnet" {
  assert {
    condition = alltrue([
      for k, v in local.vlans :
      v.net_id < pow(2, var.vlan_prefix_v6_bits - var.site_prefix_v6_bits) if local.vlan_is_derived[k]
    ])
    error_message = "A net_id does not fit in the IPv6 subnet ID bits between the site and VLAN prefix lengths."
  }
}

check "vlan_prefix_v4_unique" {
  assert {
    condition     = length(distinct(values(local.vlan_prefix_v4))) == length(local.vlan_prefix_v4)
    error_message = "Two VLANs have the same IPv4 prefix."
  }
}

check "vlan_prefix_v6_unique" {
  assert {
    condition     = length(distinct(values(local.vlan_prefix_v6))) == length(local.vlan_prefix_v6)
    error_message = "Two VLANs have the same IPv6 prefix."
  }
}

check "unique_octets_per_vlan" {
  assert {
    condition = length(local.hosts) == length(distinct([
      for name, h in local.hosts : "${h.vlan}/${h.host_octet}"
    ]))
    error_message = "Duplicate host_octet within a VLAN in hosts.yaml."
  }
}

check "ipv6_hosts_on_ipv6_vlans" {
  assert {
    condition = alltrue([
      for name, h in local.hosts :
      contains(keys(local.vlan_prefix_v6), h.vlan) if try(h.ipv6, false)
    ])
    error_message = "A host in hosts.yaml has ipv6: true but its VLAN has no IPv6 prefix (override VLANs have none)."
  }
}

check "ipv6_devices_on_ipv6_vlans" {
  assert {
    condition = alltrue([
      for k, d in local.devices :
      contains(keys(local.vlan_prefix_v6), try(local.device_vlan[k], "")) if try(d.mgmt_iid_v6, null) != null
    ])
    error_message = "A device in devices.yaml has mgmt_iid_v6 but no mgmt_ip_v4 on a VLAN with an IPv6 prefix."
  }
}

check "memory_min_within_memory" {
  assert {
    condition = alltrue([
      for name, h in local.hosts : try(h.memory_min, h.memory) <= h.memory
    ])
    error_message = "A host in hosts.yaml has memory_min greater than memory."
  }
}

# Hand-built guests outside hlac are registered as devices; a host must never
# be derived onto one of their addresses.
check "host_ips_clear_of_devices" {
  assert {
    condition = length(setintersection(
      toset(values(local.host_ipv4)),
      toset([for k, d in local.devices : d.mgmt_ip_v4 if try(d.mgmt_ip_v4, null) != null])
    )) == 0
    error_message = "A host in hosts.yaml derives an address already used by a device in devices.yaml."
  }
}

check "octets_in_static_range" {
  assert {
    condition = alltrue([
      for name, h in local.hosts :
      h.host_octet >= var.static_range[0] && h.host_octet <= var.static_range[1]
    ])
    error_message = "A host_octet falls outside the static IP range."
  }
}

check "dhcp_v4_pools_within_prefix" {
  assert {
    condition = alltrue(flatten([
      for k, octets in local.vlan_dhcp_v4_octets : [
        for octet in values(octets) :
        octet >= 1 && octet <= pow(2, 32 - tonumber(split("/", local.vlan_prefix_v4[k])[1])) - 2
      ]
    ]))
    error_message = "A DHCPv4 pool boundary falls outside its own prefix in vlans.yaml."
  }
}

check "dhcp_v4_pools_clear_static_range" {
  assert {
    condition = alltrue([
      for octets in local.vlan_dhcp_v4_octets :
      octets.dynamic_start > var.static_range[1] && octets.reservation_start > var.static_range[1]
    ])
    error_message = "A DHCPv4 pool starts inside the static IP range in vlans.yaml."
  }
}

check "dhcp_v4_dynamic_below_reservations" {
  assert {
    condition = alltrue([
      for octets in local.vlan_dhcp_v4_octets :
      octets.dynamic_start <= octets.dynamic_end &&
      octets.dynamic_end < octets.reservation_start &&
      octets.reservation_start <= octets.reservation_end
    ])
    error_message = "A dynamic pool overlaps its reservation range in vlans.yaml."
  }
}

check "device_mgmt_ip_resolves" {
  assert {
    condition     = alltrue([for k, vk in local.device_vlan : vk != null])
    error_message = "A device mgmt_ip_v4 does not fall inside any VLAN prefix at that device's site."
  }
}

check "reservations_have_a_dhcp_v4_subnet" {
  assert {
    condition = alltrue([
      for k, _ in local.reservations :
      contains(keys(local.vlan_dhcp_v4_octets), local.device_vlan[k])
    ])
    error_message = "A device reservation targets a VLAN with DHCPv4 disabled."
  }
}

check "reservations_outside_dynamic_pool" {
  assert {
    condition = alltrue([
      for k, r in local.reservations : !(
        tonumber(split(".", r.ip)[3]) >= local.vlan_dhcp_v4_octets[local.device_vlan[k]].dynamic_start &&
        tonumber(split(".", r.ip)[3]) <= local.vlan_dhcp_v4_octets[local.device_vlan[k]].dynamic_end
      )
    ])
    error_message = "A device reservation address falls inside its VLAN's dynamic pool."
  }
}

check "no_name_collisions" {
  assert {
    condition     = length(setintersection(keys(local.hosts), keys(local.devices))) == 0
    error_message = "A name appears in both hosts.yaml and devices.yaml; their DNS records would collide."
  }
}

check "public_service_backends_exist" {
  assert {
    condition     = length(local.unresolved_backends) == 0
    error_message = "public_services with no host or addressed device as backend: ${join(", ", local.unresolved_backends)}"
  }
}

check "role_services_reference_real_roles" {
  assert {
    condition = length(setsubtract(
      keys(local.role_services),
      distinct(concat(
        [for _, h in local.hosts : h.role],
        [for _, d in local.devices : d.role]
      ))
    )) == 0
    error_message = "services.yaml defines role_services for a role no host or device uses."
  }
}
