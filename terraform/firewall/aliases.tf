# One alias per node, holding its IPv4 and IPv6 addresses
resource "opnsense_firewall_alias" "node" {
  for_each = local.nodes

  name        = each.value.alias
  type        = "host"
  content     = each.value.addresses
  description = "${each.key}. Managed by hlac."
}

# One alias per role, nesting the node aliases
resource "opnsense_firewall_alias" "role" {
  for_each = local.roles

  name        = "role_${replace(each.key, "-", "_")}"
  type        = "host"
  content     = [for name in each.value : opnsense_firewall_alias.node[name].name]
  description = "Every ${each.key} host. Managed by hlac."
}

# Everything that counts as "inside" the network:
# - Every private (RFC1918) IPv4 range
# - ULA
# - Each site's IPv6 delegation
#
# Rules can negate this to mean "the internet"
resource "opnsense_firewall_alias" "internal" {
  name = "net_internal"
  type = "network"
  content = concat(
    ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16", "fc00::/7"],
    [for _, s in module.registry.sites : s.prefix_v6],
  )
  description = "Private IPv4, ULA, and every site's IPv6 delegation. Managed by hlac."
}

resource "opnsense_firewall_alias" "web_ports" {
  name        = "port_web"
  type        = "port"
  content     = ["80", "443"]
  description = "HTTP and HTTPS. Managed by hlac."
}

# What monitoring01 scrapes on edge01: node_exporter and Caddy's metrics.
resource "opnsense_firewall_alias" "edge_scrape_ports" {
  name        = "port_scrape_edge"
  type        = "port"
  content     = ["9100", "9180"]
  description = "node_exporter and Caddy metrics on edge hosts. Managed by hlac."
}
