resource "cloudflare_dns_record" "this" {
  for_each = local.records

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = try(each.value.ttl, 1)
  comment = "Managed by hlac."

  content = each.value.type == "SRV" ? null : (
    try(each.value.host, null) != null
    ? local.cloud_hosts[each.value.host][each.value.type == "A" ? "ipv4" : "ipv6"]
    : each.value.content
  )
  priority = contains(["MX", "SRV"], each.value.type) ? each.value.priority : null
  proxied  = contains(["A", "AAAA", "CNAME"], each.value.type) ? try(each.value.proxied, false) : null

  data = each.value.type != "SRV" ? null : {
    priority = each.value.priority
    weight   = each.value.weight
    port     = each.value.port
    target   = each.value.target
  }

  lifecycle {
    precondition {
      condition     = try(each.value.host, null) == null || contains(keys(local.cloud_hosts), try(each.value.host, ""))
      error_message = "${each.key} names host ${try(each.value.host, "")}, which isn't in hlac.json's cloud_hosts. Run just substrate first."
    }
  }
}
