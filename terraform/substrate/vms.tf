resource "proxmox_virtual_environment_vm" "substrate" {
  for_each = local.substrate

  name        = each.key
  description = "Managed by hlac in https://gitlab.com/klercke/homelab-as-code."
  node_name   = each.value.node
  vm_id       = module.registry.host_vmid[each.key]
  pool_id     = proxmox_virtual_environment_pool.crit[tostring(each.value.crit)].pool_id
  tags = sort([
    "hlac",
    "layer-${each.value.layer}",
    "fns-${module.registry.vlans[each.value.vlan].fns}",
    "role-${each.value.role}",
    "crit-${each.value.crit}",
  ])

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true # Must be enabled AFTER ansible base role is applied
  }

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES" # Maximum supported version on Jotunheim
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.datastore_id
    import_from  = proxmox_download_file.rocky9[each.value.node].id
    interface    = "scsi0"
    size         = each.value.disk
    discard      = "on"
    ssd          = true
    iothread     = true
  }

  dynamic "disk" {
    for_each = try([each.value.data_disk], [])
    content {
      datastore_id = var.datastore_id
      interface    = "scsi1"
      size         = disk.value
      discard      = "on"
      ssd          = true
    }
  }

  network_device {
    bridge      = "vmbr0"
    vlan_id     = module.registry.vlan_id[each.value.vlan]
    mac_address = module.registry.macs[each.key]
  }

  initialization {
    datastore_id = var.datastore_id
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = module.registry.host_cidr_v4[each.key]
        gateway = module.registry.vlan_gateway_v4[each.value.vlan]
      }
    }

    dns {
      servers = [var.bootstrap_resolver]
    }

    user_account {
      username = "ansible"
      keys     = local.authorized_keys
    }
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [node_name]

    precondition {
      condition = (
        module.registry.host_vmid[each.key] >= 100 &&
        module.registry.host_vmid[each.key] <= 999999999
      )
      error_message = "Derived VMID for ${each.key} is outside Proxmox's valid range."
    }
  }
}
