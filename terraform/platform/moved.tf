moved {
  from = netbox_vlan.this["clients"]
  to   = netbox_vlan.this["home-clients"]
}

moved {
  from = netbox_vlan.this["servers"]
  to   = netbox_vlan.this["home-servers"]
}

moved {
  from = netbox_vlan.this["iot"]
  to   = netbox_vlan.this["home-iot"]
}

moved {
  from = netbox_vlan.this["lab"]
  to   = netbox_vlan.this["home-lab"]
}

moved {
  from = netbox_vlan.this["guest"]
  to   = netbox_vlan.this["home-guest"]
}

moved {
  from = netbox_vlan.this["management"]
  to   = netbox_vlan.this["home-management"]
}

moved {
  from = netbox_vlan.this["legacy"]
  to   = netbox_vlan.this["home-legacy"]
}

moved {
  from = netbox_prefix.this["clients"]
  to   = netbox_prefix.this["home-clients"]
}

moved {
  from = netbox_prefix.this["servers"]
  to   = netbox_prefix.this["home-servers"]
}

moved {
  from = netbox_prefix.this["iot"]
  to   = netbox_prefix.this["home-iot"]
}

moved {
  from = netbox_prefix.this["lab"]
  to   = netbox_prefix.this["home-lab"]
}

moved {
  from = netbox_prefix.this["guest"]
  to   = netbox_prefix.this["home-guest"]
}

moved {
  from = netbox_prefix.this["management"]
  to   = netbox_prefix.this["home-management"]
}

moved {
  from = netbox_prefix.this["legacy"]
  to   = netbox_prefix.this["home-legacy"]
}

moved {
  from = netbox_ip_range.this["clients-dynamic"]
  to   = netbox_ip_range.this["home-clients-dynamic"]
}

moved {
  from = netbox_ip_range.this["clients-reservation"]
  to   = netbox_ip_range.this["home-clients-reservation"]
}

moved {
  from = netbox_ip_range.this["servers-dynamic"]
  to   = netbox_ip_range.this["home-servers-dynamic"]
}

moved {
  from = netbox_ip_range.this["servers-reservation"]
  to   = netbox_ip_range.this["home-servers-reservation"]
}

moved {
  from = netbox_ip_range.this["iot-dynamic"]
  to   = netbox_ip_range.this["home-iot-dynamic"]
}

moved {
  from = netbox_ip_range.this["iot-reservation"]
  to   = netbox_ip_range.this["home-iot-reservation"]
}

moved {
  from = netbox_ip_range.this["lab-dynamic"]
  to   = netbox_ip_range.this["home-lab-dynamic"]
}

moved {
  from = netbox_ip_range.this["lab-reservation"]
  to   = netbox_ip_range.this["home-lab-reservation"]
}

moved {
  from = netbox_ip_range.this["guest-dynamic"]
  to   = netbox_ip_range.this["home-guest-dynamic"]
}

moved {
  from = netbox_ip_range.this["guest-reservation"]
  to   = netbox_ip_range.this["home-guest-reservation"]
}
