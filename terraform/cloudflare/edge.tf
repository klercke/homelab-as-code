module "registry" {
  source = "../modules/registry"

  domain = "protonet.internal."
  env    = var.env
}

locals {
  # Every exposed name is a CNAME to this.
  # Its A record is managed by DDNS on fw01.
  # Its AAAA record is just edge01's.
  edge_name = "edge.${local.dns.zone}"
  edge_v6   = try(module.registry.host_records_v6[var.edge_proxy_host].ipv6, null)
}

resource "cloudflare_dns_record" "exposed" {
  for_each = module.registry.exposed_services

  zone_id = local.zone_id
  name    = each.value.hostname
  type    = "CNAME"
  content = local.edge_name
  ttl     = 1
  proxied = false
  comment = "Managed by hlac. Served by ${var.edge_proxy_host}."
}

resource "cloudflare_dns_record" "edge_aaaa" {
  count = local.edge_v6 == null ? 0 : 1

  zone_id = local.zone_id
  name    = local.edge_name
  type    = "AAAA"
  content = local.edge_v6
  ttl     = 1
  proxied = false
  comment = "Managed by hlac. The A record is OPNsense dynamic DNS."
}
