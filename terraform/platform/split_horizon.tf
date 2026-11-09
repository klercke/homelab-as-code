# Split horizon for exposed services.
# Each public hostname gets its own small zone here, answered with the edge
# proxy's internal addresses.
# The recursorsforward exactly these names, so the rest of ptxe.dev still
# resolves through Cloudflare and internal clients never hairpin through the
# WAN or NAT64.
resource "powerdns_zone" "exposed" {
  for_each = module.registry.exposed_services

  name        = "${each.value.hostname}."
  kind        = "Native"
  nameservers = local.nameservers
}

resource "powerdns_record" "exposed_a" {
  for_each = module.registry.exposed_services

  zone    = powerdns_zone.exposed[each.key].name
  name    = "${each.value.hostname}."
  type    = "A"
  ttl     = 300
  records = [module.registry.host_records_v4[var.edge_proxy_host].ipv4]
}

resource "powerdns_record" "exposed_aaaa" {
  for_each = contains(keys(module.registry.host_records_v6), var.edge_proxy_host) ? module.registry.exposed_services : {}

  zone    = powerdns_zone.exposed[each.key].name
  name    = "${each.value.hostname}."
  type    = "AAAA"
  ttl     = 300
  records = [module.registry.host_records_v6[var.edge_proxy_host].ipv6]
}
