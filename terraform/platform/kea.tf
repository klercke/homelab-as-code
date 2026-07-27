resource "kea_dhcp4_reservation" "this" {
  for_each = module.registry.reservations

  subnet_id  = each.value.subnet_id
  hw_address = each.value.mac
  ip_address = each.value.ip
  hostname   = each.value.hostname

  user_context = jsonencode({
    managed-by = "hlac"
    source     = "registries/devices.yaml"
  })
}
