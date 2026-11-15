locals {
  dns = yamldecode(file("${path.root}/../../registries/public_dns.yaml"))

  # The zone that holds edge.<zone> and every exposed service.
  edge_zone    = "ptxe.dev"
  edge_zone_id = local.dns.zones[local.edge_zone].zone_id

  # Cloud hosts' addresses from the file substrate generates.
  # A record with host: instead of content takes its address from here, so run
  # `just substrate` before just cloudflare after a cloud host changes.
  cloud_hosts = jsondecode(file("${path.root}/../../ansible/inventories/protonet/group_vars/all/hlac.json")).hlac.cloud_hosts

  # Every record in every zone, keyed "<zone>/<key>".
  records = merge([
    for zone, z in local.dns.zones : {
      for key, r in z.records : "${zone}/${key}" => merge(r, { zone_id = z.zone_id })
    }
  ]...)
}
