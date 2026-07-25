resource "proxmox_virtual_environment_pool" "crit" {
  for_each = toset(["1", "2", "3", "4"])
  pool_id  = "crit-${each.key}"
  comment  = "Criticality ${each.key}. Managed by hlac."
}
