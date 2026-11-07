module "registry" {
  source = "../modules/registry"

  domain = "protonet.internal."
  env    = var.env
}

locals {
  devices = module.registry.devices
  hosts   = module.registry.hosts

  # Every VM and every device with an address -> its addresses.
  # Alias names may only contain letters, digits and underscores.
  nodes = merge(
    {
      for name, r in module.registry.device_records_v4 : name => {
        alias = "host_${replace(name, "-", "_")}"
        role  = local.devices[name].role
        addresses = compact([
          r.ipv4,
          try(module.registry.device_records_v6[name].ipv6, null),
        ])
      }
    },
    {
      for name, r in module.registry.host_records_v4 : name => {
        alias = "host_${replace(name, "-", "_")}"
        role  = local.hosts[name].role
        addresses = compact([
          r.ipv4,
          try(module.registry.host_records_v6[name].ipv6, null),
        ])
      }
    },
  )

  # Role -> the nodes holding it
  roles = {
    for role, names in { for name, n in local.nodes : n.role => name... } :
    role => sort(names)
  }
}
