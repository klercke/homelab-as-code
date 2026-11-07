module "registry" {
  source = "../modules/registry"

  domain = local.domain
  env    = var.env
}

locals {
  hosts = module.registry.hosts

  dns_records    = merge(module.registry.host_records_v4, module.registry.device_records_v4)
  dns_records_v6 = merge(module.registry.host_records_v6, module.registry.device_records_v6)
}
