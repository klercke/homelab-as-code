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
