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
