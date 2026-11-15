# Cloud hosts from registries/cloud.yaml.
# Ansible picks them up from the generated cloud.yml.
resource "linode_instance" "cloud" {
  for_each = local.cloud_linode

  label           = each.key
  region          = each.value.region
  type            = each.value.plan
  image           = each.value.image
  authorized_keys = local.authorized_keys # Must be set when using an image
  tags = sort([
    "hlac",
    "layer-${each.value.layer}",
    "role-${each.value.role}",
    "crit-${each.value.crit}",
  ])

  backups_enabled = try(each.value.backups, false)

  metadata {
    user_data = base64encode(local.cloud_init[each.key])
  }

  lifecycle {
    # Image and user data only matter at creation.
    # Changing either must not rebuild a running host.
    # authorized_keys is used for initial setup, then taken over by Ansible.
    ignore_changes = [image, metadata, authorized_keys]
  }
}

resource "linode_firewall" "cloud" {
  for_each = local.cloud_linode

  label           = "${each.key}-fw"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "icmp"
    action   = "ACCEPT"
    protocol = "ICMP"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  dynamic "inbound" {
    for_each = local.cloud_firewall_rules[each.key]
    content {
      label    = inbound.value.label
      action   = "ACCEPT"
      protocol = inbound.value.protocol
      ports    = inbound.value.ports
      ipv4     = ["0.0.0.0/0"]
      ipv6     = ["::/0"]
    }
  }

  linodes = [linode_instance.cloud[each.key].id]
}

# Linode refuses rDNS unless the name already resolves to the address, so a new
# host's rdns: goes in after its forward records (just cloudflare).
locals {
  cloud_rdns = { for k, h in local.cloud_linode : k => h.rdns if try(h.rdns, null) != null }
}

resource "linode_rdns" "cloud_v4" {
  for_each = local.cloud_rdns

  address = linode_instance.cloud[each.key].ip_address
  rdns    = each.value
}

resource "linode_rdns" "cloud_v6" {
  for_each = local.cloud_rdns

  address = split("/", linode_instance.cloud[each.key].ipv6)[0]
  rdns    = each.value
}
