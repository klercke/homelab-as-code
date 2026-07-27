module "registry" {
  source = "../modules/registry"
}

locals {
  sites = yamldecode(file("${path.root}/../../registries/sites.yaml")).sites
  vlans = yamldecode(file("${path.root}/../../registries/vlans.yaml")).vlans
  hosts = yamldecode(file("${path.root}/../../registries/hosts.yaml")).hosts

  role_colors = {
    postgres = "336791" #336791
    netbox   = "00d9ff" #00d9ff
    pdns     = "4caf50" #4caf50
    kea      = "ff9800" #ff9800
    recursor = "8bc34a" #8bc34a
    valkey   = "f44336" #f44336
  }

  vdisks = merge([
    for hname, h in module.registry.hosts : merge(
      { "${hname}-os" = { host = hname, name = "scsi0", size = h.disk } },
      try(h.data_disk, null) == null ? {} :
      { "${hname}-data" = { host = hname, name = "scsi1", size = h.data_disk } }
    )
  ]...)

  ip_ranges = merge([
    for name, v in module.registry.vlans : {
      "${name}-dynamic" = {
        start    = v.dhcp.dynamic_start
        end      = v.dhcp.dynamic_end
        desc     = "Dynamic pool"
        vlan     = name
        utilized = true
      }
      "${name}-reservation" = {
        start    = v.dhcp.reservation_start
        end      = v.dhcp.reservation_end
        desc     = "DHCP reservations"
        vlan     = name
        utilized = false
      }
    } if try(v.dhcp.enabled, false)
  ]...)

  reserved_devices = module.registry.reservations

  dns_records = merge(module.registry.host_records, module.registry.device_records)
}
