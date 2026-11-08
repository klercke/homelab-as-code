locals {
  dns = yamldecode(file("${path.root}/../../registries/public_dns.yaml"))

  # Not secret: it appears in every Cloudflare API URL for the zone.
  zone_id = "6994338dbca6b4685e53f2ab0be6c48f"
}
