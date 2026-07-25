module "registry" {
  source = "../modules/registry"
}

locals {
  # This module owns L1 (substrate) only
  # Filtering here means adding an L2 host to the registry doesn't silently pull it into the substrate state
  substrate = {
    for k, v in module.registry.hosts : k => v if v.layer == "l1"
  }

  nodes = toset([for _, h in local.substrate : h.node])

  authorized_keys = [
    trimspace(file("${path.root}/../../keys/protonet_admin.pub")),
    # add keys/protonet_ci.pub here when CI exists
  ]
}
