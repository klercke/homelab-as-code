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


## Inventories

| Name | Description |
|------|-------------|
| protonet/proxmox | All Proxmox VE VMs with the `hlac` tag in the cluster |
