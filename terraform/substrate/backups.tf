resource "proxmox_backup_job" "crit1" {
  id       = "protonet-crit1"
  schedule = "1/4:30"
  storage  = var.pbs_storage
  mode     = "snapshot"

  pool = proxmox_virtual_environment_pool.crit["1"].pool_id

  notes_template = "{{guestname}} via hlac"
}

resource "proxmox_backup_job" "crit2" {
  id       = "protonet-crit2"
  schedule = "2/12:00"
  storage  = var.pbs_storage
  mode     = "snapshot"

  pool = proxmox_virtual_environment_pool.crit["2"].pool_id

  notes_template = "{{guestname}} via hlac"
}

resource "proxmox_backup_job" "crit3" {
  id       = "protonet-crit3"
  schedule = "3:30"
  storage  = var.pbs_storage
  mode     = "snapshot"

  pool = proxmox_virtual_environment_pool.crit["3"].pool_id

  notes_template = "{{guestname}} via hlac"
}

resource "proxmox_backup_job" "crit4" {
  id       = "protonet-crit4"
  schedule = "sun 5:00"
  storage  = var.pbs_storage
  mode     = "snapshot"

  pool = proxmox_virtual_environment_pool.crit["4"].pool_id

  notes_template = "{{guestname}} via hlac"
}
