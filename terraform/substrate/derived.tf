# Derived network facts for Ansible
#
# Since Ansible can't read HCL (easily), this file creates a JSON file for
# Ansible to operate off of.
# The generated file can be committed as long as a substrate apply is always
# done before Ansible operations.
resource "local_file" "derived_network" {
  filename        = "${path.root}/../../ansible/inventories/${var.ansible_inventory_name}/group_vars/all/hlac.json"
  file_permission = "0644"

  content = jsonencode({
    hlac = {
      _generated_by = "terraform/substrate, do not edit by hand"

      sites = {
        for k, s in module.registry.sites : k => {
          name       = s.name
          slug       = s.slug
          site_index = module.registry.site_index[k]
          prefix_v4  = s.prefix_v4
        }
      }

      vlans = {
        for k, v in module.registry.vlans : k => {
          name       = v.name
          fns        = v.fns
          site       = v.site
          vlan_id    = module.registry.vlan_id[k]
          prefix_v4  = module.registry.vlan_prefix_v4[k]
          gateway_v4 = module.registry.vlan_gateway_v4[k]
          status     = v.status

          dhcp_v4 = try({
            subnet_id         = module.registry.vlan_id[k]
            dynamic_start     = module.registry.vlan_dhcp_v4[k].dynamic_start
            dynamic_end       = module.registry.vlan_dhcp_v4[k].dynamic_end
            reservation_start = module.registry.vlan_dhcp_v4[k].reservation_start
            reservation_end   = module.registry.vlan_dhcp_v4[k].reservation_end
          }, null)
        }
      }

      hosts = {
        for k, h in module.registry.hosts : k => {
          vlan    = h.vlan
          site    = module.registry.host_site[k]
          role    = h.role
          layer   = h.layer
          crit    = h.crit
          ipv4    = module.registry.host_ipv4[k]
          cidr_v4 = module.registry.host_cidr_v4[k]
          fqdn    = module.registry.host_records_v4[k].fqdn
        }
      }

      devices = {
        for k, d in module.registry.devices : k => {
          role        = d.role
          site        = d.site
          device_type = d.device_type
          status      = try(d.status, "active")
          vlan        = try(module.registry.device_vlan[k], null)
          ipv4        = try(d.mgmt_ip, null)
          cidr_v4     = try(module.registry.device_mgmt_cidr_v4[k], null)
          fqdn        = try(module.registry.device_records_v4[k].fqdn, null)
        }
      }

      role_services = module.registry.role_services

      public_services = {
        for k, s in module.registry.public_services : k => {
          backend      = s.backend
          backend_ipv4 = module.registry.backend_records_v4[s.backend].ipv4
          backend_fqdn = module.registry.backend_records_v4[s.backend].fqdn
          port         = s.port
          scheme       = try(s.scheme, "http")
          description  = try(s.description, null)
        }
      }

      vm_services     = module.registry.vm_services
      device_services = module.registry.device_services

      reverse_zones_v4 = module.registry.reverse_zones_v4
    }
  })
}
