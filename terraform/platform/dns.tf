locals {
  # Base DNS info
  domain      = "protonet.internal."
  nameservers = ["ns1.${local.domain}", "ns2.${local.domain}"]

  # From the host, get the VLAN. From the VLAN, get the site slug for the A record
  host_site = {
    for name, h in local.hosts :
    name => local.vlans[h.vlan].site
  }

  # /24 prefix -> reverse zone name, e.g. 10.0.20.0/24 -> 20.0.10.in-addr.arpa.
  reverse_zones = {
    for k, v in local.vlans :
    k => "${join(".", slice(reverse(split(".", split("/", v.prefix)[0])), 1, 4))}.in-addr.arpa."
  }

  # Substrate host FQDNs and IPs
  host_records = {
    for name, h in local.hosts :
    name => {
      fqdn     = "${name}.${var.env}.${local.sites[local.host_site[name]].slug}.${local.domain}"
      ipv4     = cidrhost(local.vlans[h.vlan].prefix, h.host_octet)
      ptr_name = "${join(".", reverse(split(".", cidrhost(local.vlans[h.vlan].prefix, h.host_octet))))}.in-addr.arpa."
      rev_zone = local.reverse_zones[h.vlan]
    }
  }

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

# NS aliases ns1/ns2 for the two pdns hosts, so the NS records resolve
resource "powerdns_record" "ns_alias" {
  for_each = local.ns_targets

  zone    = powerdns_zone.forward.name
  name    = "${each.key}.protonet.internal."
  type    = "A"
  ttl     = 300
  records = [each.value]
}
