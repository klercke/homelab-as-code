# Registries

Machine-readable source data for ProtoNet.
These files are the authoritative definition of everything ProtoNet is made of: sites, VLANs, hosts, devices, services, public DNS, and LLM routing.
OpenTofu and Ansible build everything else from them.

## Files

| File | What it defines |
|---|---|
| `sites.yaml` | Physical sites, each owning one IPv4 /16 and their own IPv6 prefix |
| `vlans.yaml` | VLANs and their prefixes, DHCP pools, and reverse zones |
| `hosts.yaml` | Proxmox VMs, including role, VLAN, size, criticality |
| `cloud.yaml` | Hosts at a cloud provider, built by substrate alongside the PVE VMs |
| `devices.yaml` | Physical devices, racks, and device models, for NetBox and the device inventory |
| `services.yaml` | What each host and role listens on, and the internal names published behind Caddy |
| `public_dns.yaml` | Public DNS records, applied to Cloudflare |
| `models.yaml` | LLM routing: which models exist, where they run, and how clients reach them |

## Consumers

OpenTofu reads the registries through one module, `terraform/modules/registry`, so every layer sees the same derived values.
Ansible mostly reads them through `hlac.json`, which `terraform/substrate` writes from that module's outputs.

| File | OpenTofu | Ansible |
|---|---|---|
| `sites.yaml` | NetBox sites | via `hlac.json` |
| `vlans.yaml` | NetBox VLANs and prefixes, Kea subnets and pools, PowerDNS reverse zones | firewall rules and resolver config, via `hlac.json` |
| `hosts.yaml` | Proxmox VMs, DNS records, Kea reservations, firewall aliases, NetBox VMs | host vars and group membership, via `hlac.json` |
| `cloud.yaml` | Cloud hosts, the `cloud.yml` inventory, NetBox | the `cloud.yml` inventory |
| `devices.yaml` | DNS records, firewall aliases, NetBox devices and racks, the `devices.yml` inventory | the `devices.yml` inventory, and device services via `hlac.json` |
| `services.yaml` | NetBox services, internal and public DNS names | Caddy sites, Prometheus targets, firewall ports, via `hlac.json` |
| `public_dns.yaml` | Cloudflare records (`terraform/cloudflare`) | - |
| `models.yaml` | - | LiteLLM routes (llm role, read directly) |

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

Some values are computed by consumers rather than stored here, because storing them could cause drift:

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
