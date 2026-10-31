locals {
  # Base DNS info
  domain             = "protonet.internal."
  int_service_domain = "int.ptxe.dev."
  nameservers        = ["ns1.${local.domain}", "ns2.${local.domain}"]

  host_site     = module.registry.host_site
  reverse_zones = module.registry.reverse_zones_v4
  host_records  = module.registry.host_records_v4

  # The authoritative PowerDNS hosts, sorted
  ns_hosts = {
    for name, h in local.hosts : name => h if h.role == "pdns"
  }

  ns_targets = {
    for idx, name in sort(keys(local.ns_hosts)) :
    "ns${idx + 1}" => local.host_records[name].ipv4
  }
}

resource "powerdns_zone" "forward" {
  name        = local.domain
  kind        = "Native"
  nameservers = local.nameservers
}

resource "powerdns_zone" "reverse" {
  for_each = toset(values(local.reverse_zones))

  name        = each.value
  kind        = "Native"
  nameservers = local.nameservers
}

resource "powerdns_zone" "reverse_v6" {
  for_each = toset(values(module.registry.reverse_zones_v6))

  name        = each.value
  kind        = "Native"
  nameservers = local.nameservers
}

# A records for every host
resource "powerdns_record" "a" {
  for_each = local.dns_records

  zone    = powerdns_zone.forward.name
  name    = each.value.fqdn
  type    = "A"
  ttl     = 300
  records = [each.value.ipv4]
}

# PTR records for every host
resource "powerdns_record" "ptr" {
  for_each = local.dns_records

  zone    = powerdns_zone.reverse[each.value.rev_zone].name
  name    = each.value.ptr_name
  type    = "PTR"
  ttl     = 300
  records = [each.value.fqdn]
}

# AAAA and PTR records for hosts with ipv6: true and devices with mgmt_iid_v6
resource "powerdns_record" "aaaa" {
  for_each = local.dns_records_v6

  zone    = powerdns_zone.forward.name
  name    = each.value.fqdn
  type    = "AAAA"
  ttl     = 300
  records = [each.value.ipv6]
}

resource "powerdns_record" "ptr_v6" {
  for_each = local.dns_records_v6

  zone    = powerdns_zone.reverse_v6[each.value.rev_zone].name
  name    = each.value.ptr_name
  type    = "PTR"
  ttl     = 300
  records = [each.value.fqdn]
}

# NS aliases ns1/ns2 for the two pdns hosts, so the NS records resolve
resource "powerdns_record" "ns_alias" {
  for_each = local.ns_targets

  zone    = powerdns_zone.forward.name
  name    = "${each.key}.${local.domain}"
  type    = "A"
  ttl     = 300
  records = [each.value]
}

resource "powerdns_zone" "public_internal" {
  name        = local.int_service_domain
  kind        = "Native"
  nameservers = local.nameservers
}

resource "powerdns_record" "service" {
  for_each = module.registry.public_services

  zone    = powerdns_zone.public_internal.name
  name    = "${each.key}.${local.int_service_domain}"
  type    = "A"
  ttl     = 300
  records = [module.registry.host_records_v4[var.internal_proxy_host].ipv4]
}

# Firefox DoH canary
# https://support.mozilla.org/kb/canary-domain-use-application-dnsnet
resource "powerdns_zone" "doh_canary" {
  name        = "use-application-dns.net."
  kind        = "Native"
  nameservers = local.nameservers
}
