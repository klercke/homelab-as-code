locals {
  dev         = module.registry.devices
  dtypes      = module.registry.device_types
  droles      = module.registry.device_roles
  racks       = module.registry.racks
  all_regions = merge(netbox_region.l0, netbox_region.l1, netbox_region.l2)

  manufacturers = toset([for _, t in local.dtypes : t.manufacturer])

  # Devices that sit in a rack as opposed to a bay or nowhere
  racked_devices = {
    for k, d in local.dev : k => d if try(d.rack, null) != null
  }

  # Devices that slot into a bay in another device
  child_devices = {
    for k, d in local.dev : k => d if try(d.parent, null) != null
  }

  # Devices with recorded management IPs
  managed_devices = {
    for k, d in local.dev : k => d if try(d.mgmt_ip, null) != null
  }

  # Devices that have other devices slotted into them
  device_bays = merge([
    for dkey, d in local.dev : {
      for n in range(1, try(local.dtypes[d.device_type].bays, 0) + 1) :
      "${dkey}/${n}" => {
        device = dkey
        number = n
        installed = one([
          for ckey, c in local.child_devices : ckey
          if c.parent == dkey && c.bay == n
        ])
      }
    } if try(local.dtypes[d.device_type].bays, 0) > 0
  ]...)

}

resource "netbox_site" "this" {
  for_each         = local.sites
  name             = each.value.name
  slug             = each.value.slug
  status           = each.value.status
  region_id        = try(local.all_regions[each.value.region].id, null)
  latitude         = try(var.site_location[each.key].latitude, null)
  longitude        = try(var.site_location[each.key].longitude, null)
  physical_address = try(var.site_location[each.key].physical_address, null)
}

resource "netbox_region" "l0" {
  for_each = { for k, r in module.registry.regions : k => r if r.depth == 0 }
  name     = each.value.name
  slug     = each.key
}

resource "netbox_region" "l1" {
  for_each         = { for k, r in module.registry.regions : k => r if r.depth == 1 }
  name             = each.value.name
  slug             = each.key
  parent_region_id = netbox_region.l0[each.value.parent].id
}

resource "netbox_region" "l2" {
  for_each         = { for k, r in module.registry.regions : k => r if r.depth == 2 }
  name             = each.value.name
  slug             = each.key
  parent_region_id = netbox_region.l1[each.value.parent].id
}

resource "netbox_location" "this" {
  for_each = module.registry.locations
  name     = each.value.name
  slug     = each.key
  site_id  = netbox_site.this[each.value.site].id
}

resource "netbox_manufacturer" "this" {
  for_each = local.manufacturers
  name     = each.value
}

resource "netbox_device_role" "physical" {
  for_each = local.droles

  name      = each.value.name
  color_hex = each.value.color
  vm_role   = false
}

resource "netbox_device_type" "this" {
  for_each = local.dtypes

  manufacturer_id = netbox_manufacturer.this[each.value.manufacturer].id
  model           = each.value.model
  slug            = each.key
  u_height        = each.value.u_height
  is_full_depth   = each.value.full_depth
  subdevice_role  = try(each.value.subdevice_role, null)
  tags            = [netbox_tag.hlac.name]
}

resource "netbox_rack" "this" {
  for_each = local.racks

  name        = each.value.name
  site_id     = netbox_site.this[each.value.site].id
  u_height    = each.value.u_height
  form_factor = try(each.value.form_factor, "4-post-frame")
  desc_units  = try(each.value.desc_units, false)
  location_id = netbox_location.this[each.value.location].id
  status      = "active"
  tags        = [netbox_tag.hlac.name]
}

resource "netbox_device" "this" {
  for_each = local.dev

  name           = each.key
  device_type_id = netbox_device_type.this[each.value.device_type].id
  role_id        = netbox_device_role.physical[each.value.role].id
  site_id        = netbox_site.this[each.value.site].id
  status         = try(each.value.status, "active")
  description    = try(each.value.description, null)
  serial         = try(each.value.serial, null)

  # Null for bay-installed and unracked devices.
  rack_id       = try(each.value.rack, null) == null ? null : netbox_rack.this[each.value.rack].id
  rack_position = try(each.value.position, null)
  rack_face     = try(each.value.rack, null) == null ? null : try(each.value.face, "front")

  tags = [netbox_tag.hlac.name]

  lifecycle {
    ignore_changes = [location_id] # Inherited from rack
  }
}

resource "netbox_device_bay" "this" {
  for_each = local.device_bays

  device_id           = netbox_device.this[each.value.device].id
  name                = "Bay ${each.value.number}"
  installed_device_id = each.value.installed == null ? null : netbox_device.this[each.value.installed].id
}

resource "netbox_device_interface" "mgmt" {
  for_each = local.managed_devices

  device_id = netbox_device.this[each.key].id
  name      = "mgmt"
  type      = "1000base-t"
  enabled   = true
}

resource "netbox_ip_address" "device_mgmt" {
  for_each = local.managed_devices

  ip_address   = module.registry.device_mgmt_cidr_v4[each.key]
  status       = "active"
  dns_name     = "${each.key}.${var.env}.${netbox_site.this[each.value.site].slug}.protonet.internal"
  interface_id = netbox_device_interface.mgmt[each.key].id
  object_type  = "dcim.interface"
  tags         = [netbox_tag.hlac.name]
}

resource "netbox_device_primary_ip" "this" {
  for_each = local.managed_devices

  device_id     = netbox_device.this[each.key].id
  ip_address_id = netbox_ip_address.device_mgmt[each.key].id
}
