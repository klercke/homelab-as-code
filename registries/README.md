# Registries

Machine-readable source data for ProtoNet.
These files are the authoritative definition of sites, VLANs, prefixes, and managed hosts.
Both OpenTofu and Ansible read them directly.

## Consumers

| File | OpenTofu | Ansible |
|---|---|---|
| `sites.yaml` | NetBox sites | - |
| `vlans.yaml` | NetBox VLANs and prefixes, DHCP pools, Reverse DNS zones | firewall rules, resolver config |
| `hosts.yaml` | Core/substrate VM definitions, NetBox devices | host vars, group membership |

### Terraform Example

```hcl
locals {
  vlans = yamldecode(file("${path.root}/../../registries/vlans.yaml")).vlans
}
```

### Ansible Example

```yaml
- ansible.builtin.include_vars:
    file: "{{ playbook_dir }}/../../registries/vlans.yaml"
```

## Rules

**Quote every string value.**
OpenTofu's `yamldecode` implements YAML 1.2.
Ansible parses YAML 1.1 through PyYAML.
They disagree on unquoted scalars:

- `no`, `yes`, `on`, `off`, `y`, `n` become booleans under 1.1, strings under 1.2
- `010` is octal 8 under 1.1, the integer 10 under 1.2
- `12:34:56` is base-60 under 1.1, a string under 1.2

The same file would then mean different things to Terraform and Ansible.
Quoting every string removes the ambiguity.
Integers and booleans stay bare.

This is enforced by `yamllint` (`quoted-strings` and `truthy` rules) using `prek`.

**Structure is validated by JSON Schema** in `schemas/`, run by `check-jsonschema` via `prek`.
Every object sets `"additionalProperties": false`, so a typo'd key fails the commit rather than being silently ignored.

**Maps, not lists.**
Every collection is keyed by its natural identifier so Terraform can `for_each` over it directly.

## Derived values

Some values are computed by consumers rather than stored here, because storing
them would allow drift:

| Value | Derivation |
|---|---|
| Site index | second octet of `sites[site].prefix_v4` |
| 802.1Q VLAN ID | class digit of the site + `net_id` (override VLANs: `vlan_id`) |
| VLAN IPv4 prefix | `/24` number `net_id` inside `sites[site].prefix_v4` (override VLANs: `prefix_v4`) |
| IPv4 address | VLAN IPv4 prefix + `host.host_octet` |
| Proxmox VMID | VLAN ID `* 1000 + host.host_octet` |
| MAC address | `02:` + first 5 octets of `sha256(hostname)` |
| Reverse DNS zone | third, second, first octets of the VLAN IPv4 prefix + `.in-addr.arpa` |
| Proxmox tags | `hlac`, `layer-<layer>`, `role-<role>`, `fns-<fns>`, `crit-<crit>` |

All derivations live in `terraform/modules/registry`.

## Adding a VLAN

1. Add the entry to `vlans.yaml`
2. `prek run --all-files` to validate
3. `tofu apply` in `terraform/platform` to create the NetBox VLAN and prefix, the Kea subnet, and the PowerDNS reverse zone
