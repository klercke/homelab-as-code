locals {
  dns = yamldecode(file("${path.root}/../../registries/public_dns.yaml"))

  # The zone that holds edge.<zone> and every exposed service.
  edge_zone    = "ptxe.dev"
  edge_zone_id = local.dns.zones[local.edge_zone].zone_id

  # Every record in every zone, keyed "<zone>/<key>".
  records = merge([
    for zone, z in local.dns.zones : {
      for key, r in z.records : "${zone}/${key}" => merge(r, { zone_id = z.zone_id })
    }
  ]...)
}
