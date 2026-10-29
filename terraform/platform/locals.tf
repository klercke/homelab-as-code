module "registry" {
  source = "../modules/registry"

  domain = local.domain
  env    = "prd"
}

locals {
  sites = module.registry.sites
  vlans = module.registry.vlans
  hosts = module.registry.hosts

  fns_roles = {
    for fns, names in { for k, v in local.vlans : v.fns => v.name... } :
    fns => names[0]
  }

  # Colors are commented so that Neovim renders them for me :)
  role_colors = {
    postgres = "336791" #336791
    netbox   = "00d9ff" #00d9ff
    pdns     = "4caf50" #4caf50
    kea      = "ff9800" #ff9800
    recursor = "8bc34a" #8bc34a
    valkey   = "f44336" #f44336
  }

  vdisks = merge([
    for hname, h in local.hosts : merge(
      { "${hname}-os" = { host = hname, name = "scsi0", size = h.disk } },
      try(h.data_disk, null) == null ? {} :
      { "${hname}-data" = { host = hname, name = "scsi1", size = h.data_disk } }
    )
  ]...)

  ip_ranges = merge([
    for name, pools in module.registry.vlan_dhcp_v4 : {
      "${name}-dynamic" = {
        start    = pools.dynamic_start
        end      = pools.dynamic_end
        desc     = "Dynamic pool"
        vlan     = name
        utilized = true
      }
      "${name}-reservation" = {
        start    = pools.reservation_start
        end      = pools.reservation_end
        desc     = "DHCP reservations"
        vlan     = name
        utilized = false
      }
    }
  ]...)

  reserved_devices = module.registry.reservations
  dns_records      = merge(module.registry.host_records_v4, module.registry.device_records_v4)
}
