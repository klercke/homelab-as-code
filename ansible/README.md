# Ansible Documentation

## Playbooks

| Name | Description |
|------|-------------|
| base | Applies the base role |
| postgres | Applies the Postgres role |
| valkey | Applies the Valkey role |
| netbox | Applies the NetBox role |
| powerdns | Applies the PowerDNS role |
| recursor | Applies the Recursor role |
| kea | Applies the Kea role |
| caddy | Applies the Caddy role |
| monitoring | Applies the monitoring role |

## Roles

| Name | Description |
|------|-------------|
| base | Performs basic first-time configuration of a VM. Targets Rocky Linux 9, but may work on other distros. Should be run on every new VM. |
| postgres | Installs and configures PostgreSQL to be used by other servers. |
| valkey | Installs and configures Valkey to be used by other servers. |
| netbox | Installs and configures Netbox using the existing Postgres and Valkey servers. |
| powerdns | Installs and configures PowerDNS Authoritative. Servers with this role will only be reachable by servers with the `recursor` role. |
| recursor | Installs and configures PowerDNS Recursor. This acts as a DNS server for downstream clients, pointing toward servers with the `powerdns` role. |
| kea | Installs and configures ISC Kea. |
| caddy | Installs and configures Caddy reverse proxy for TLS termination for `public_services`.
| monitoring | Installs Grafana and Prometheus and configures them to scrape other hosts. |

## Tags

Every role task carries tags, so a role can be rerun in part.
Untagged runs (`just base`, `just role kea`) still run everything.
Playbook `pre_tasks` that load secrets or build variables are tagged `always`, so they run on tagged runs too.

| Tag | Covers |
|------|--------|
| `install` | Vendor repos, packages, downloads, users, schema setup. The slow part. |
| `config` | Templates, config files, and their validation. |
| `firewall` | firewalld rules. |
| `service` | Enabling and starting units. |
| `dns`, `ipv6`, `ssh`, `updates`, `bootloader`, `node_exporter` | Areas of the base role. |
| `prometheus`, `grafana`, `dashboards` | Areas of the monitoring role. |
| `exporter`, `backups` | Areas of the postgres role. |
| `keys` | LiteLLM key registration in the llm role. |

Examples:

```sh
just base --limit pdns01 --tags dns
just base --skip-tags install
just role kea --limit kea01 --tags config
just role monitoring --tags dashboards
```

A tagged run can skip a step that an untagged first run would do, so build new hosts with an untagged run.

## Inventories

| Name | Description |
|------|-------------|
| protonet/proxmox | All Proxmox VE VMs with the `hlac` tag in the cluster |
