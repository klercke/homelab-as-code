resource "proxmox_download_file" "rocky9" {
  for_each = local.nodes

  content_type       = "import"
  datastore_id       = "local"
  node_name          = each.key
  url                = var.rocky9_image_url
  file_name          = "rocky-9-genericcloud.qcow2"
  checksum           = var.rocky9_image_sha256
  checksum_algorithm = "sha256"
  overwrite          = false
}
