resource "cloudflare_dns_record" "this" {
  for_each = local.dns.records

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = try(each.value.ttl, 1)
  comment = "Managed by hlac."

  content  = each.value.type == "SRV" ? null : each.value.content
  priority = contains(["MX", "SRV"], each.value.type) ? each.value.priority : null
  proxied  = contains(["A", "AAAA", "CNAME"], each.value.type) ? try(each.value.proxied, false) : null

  data = each.value.type != "SRV" ? null : {
    priority = each.value.priority
    weight   = each.value.weight
    port     = each.value.port
    target   = each.value.target
  }
}
