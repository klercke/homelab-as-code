module "registry" {
  source = "../modules/registry"

  domain = "protonet.internal."
  env    = "prd"
}

locals {
  # This module owns L1 (substrate) only
  # Filtering here means adding an L2 host to the registry doesn't silently pull it into the substrate state
  substrate = {
    for k, v in module.registry.hosts : k => v if v.layer == "l1"
  }

  # Cloud hosts follow the same layer rule as VMs
  cloud = {
    for k, v in module.registry.cloud_hosts : k => v if v.layer == "l1"
  }
  cloud_linode = { for k, v in local.cloud : k => v if v.provider == "linode" }

  # Inbound rules for each cloud host's provider firewall, from its public services.
  # Linode firewalls only know TCP, UDP and ICMP.
  cloud_firewall_rules = {
    for hk, _ in local.cloud_linode : hk => [
      for sk, s in module.registry.cloud_services : {
        label    = substr(replace(lower("${s.name}-${s.protocol}"), "/[^a-z0-9_.-]/", "-"), 0, 32)
        protocol = upper(s.protocol)
        ports    = join(",", [for p in s.ports : tostring(p)])
      } if s.target == hk && s.public && contains(["tcp", "udp"], s.protocol)
    ]
  }

  cloud_init = {
    for k, h in local.cloud_linode : k => "#cloud-config\n${yamlencode({
      hostname     = k
      disable_root = true
      ssh_pwauth   = false
      packages     = ["policycoreutils-python-utils"]
      users = [{
        name                = "ansible"
        groups              = ["wheel"]
        sudo                = "ALL=(ALL) NOPASSWD:ALL"
        shell               = "/bin/bash"
        lock_passwd         = true
        ssh_authorized_keys = local.authorized_keys
      }]
      # sshd listens on 22 and ssh_port.
      # Only ssh_port is open in the Linode firewall; 22 is kept as a way back
      # in if the port move fails (manually open it in the firewall
      # temporarily).
      # The web role removes it when webssh needs 22.
      # Ansible owns this file after the first run.
      write_files = [{
        path        = "/etc/ssh/sshd_config.d/10-hlac-port.conf"
        permissions = "0600"
        content     = "Port 22\nPort ${h.ssh_port}\n"
      }]
      runcmd = [
        "semanage port -a -t ssh_port_t -p tcp ${h.ssh_port} || semanage port -m -t ssh_port_t -p tcp ${h.ssh_port}",
        "if systemctl is-active -q firewalld; then firewall-cmd --permanent --add-port=${h.ssh_port}/tcp && firewall-cmd --reload; fi",
        "systemctl restart sshd",
      ]
    })}"
  }

  nodes = toset([for _, h in local.substrate : h.node])

  authorized_keys = [
    trimspace(file("${path.root}/../../keys/protonet_admin.pub")),
    # add keys/protonet_ci.pub here when CI exists
  ]
}
