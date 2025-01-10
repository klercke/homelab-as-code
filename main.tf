resource "linode_instance" "authentik" {
  label           = "PTXE-LND-AUTH-01"
  image           = "linode/rocky9"
  region          = "us-east"
  type            = "g6-standard-1"
  tags            = ["prod", "hlac", "tofu"]
  backups_enabled = true

  authorized_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5N4dkir2ZB3jSrTH8C74ySTXDJZn6eCURIJGOpxdA5 d0c@hlac"
  ]
}

resource "njalla_record_a" "auth" {
  domain  = "ptxe.dev"
  name    = "auth"
  ttl     = 900
  content = linode_instance.authentik.ip_address
}

resource "linode_instance" "monitoring" {
  label           = "PTXE-LND-MON-01"
  image           = "linode/rocky9"
  region          = "us-east"
  type            = "g6-nanode-1"
  tags            = ["prod", "hlac", "tofu", "monitoring"]
  backups_enabled = true

  authorized_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5N4dkir2ZB3jSrTH8C74ySTXDJZn6eCURIJGOpxdA5 d0c@hlac"
  ]
}

resource "njalla_record_a" "mon" {
  domain  = "ptxe.dev"
  name    = "mon"
  ttl     = 900
  content = linode_instance.monitoring.ip_address
}

resource "local_file" "mon_hostvars" {
  filename = "${path.module}/ansible/inventories/production/host_vars/${linode_instance.monitoring.label}.yml"
  content  = "fqdn: mon.ptxe.dev"
}
