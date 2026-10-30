# Substrate

This contains the baseline required to build the rest of the network.

## Proxmox access

OpenTofu authenticates to Proxmox as `terraform@pve` with an API token, through the custom role `Terraform` granted on `/`.
The role is created by hand on the node and is not managed by this repo.
It holds only what the resources in this module need, so a leaked token cannot manage users, permissions, realms, or the guest agent.

| Privileges | Needed for |
|---|---|
| `VM.Allocate`, `VM.Audit`, `VM.Config.*` (CDROM, CPU, Cloudinit, Disk, HWType, Memory, Network, Options), `VM.PowerMgmt` | `proxmox_virtual_environment_vm`: create, configure, start, and destroy guests |
| `VM.GuestAgent.Audit` | Reading guest IP addresses through the QEMU guest agent |
| `VM.Backup` | `proxmox_backup_job` over the guests in each pool |
| `Pool.Allocate`, `Pool.Audit` | `proxmox_virtual_environment_pool` and pool membership |
| `Datastore.AllocateSpace`, `Datastore.AllocateTemplate`, `Datastore.Audit` | VM disks, the cloud-init drive, the downloaded Rocky image, and `import_from` |
| `SDN.Use`, `SDN.Audit` | Attaching NICs to `vmbr0` |
| `Sys.Audit`, `Sys.Modify`, `Sys.AccessNetwork` | Cluster backup jobs and `proxmox_download_file` (download-url) |

`Sys.Modify` on `/` is the broadest privilege left, and backup jobs cannot be created without it.

Create the role on a new node:

```
pveum role add Terraform --privs "Datastore.AllocateSpace,Datastore.AllocateTemplate,Datastore.Audit,Pool.Allocate,Pool.Audit,SDN.Audit,SDN.Use,Sys.AccessNetwork,Sys.Audit,Sys.Modify,VM.Allocate,VM.Audit,VM.Backup,VM.Config.CDROM,VM.Config.CPU,VM.Config.Cloudinit,VM.Config.Disk,VM.Config.HWType,VM.Config.Memory,VM.Config.Network,VM.Config.Options,VM.GuestAgent.Audit,VM.PowerMgmt"
```

## Terraform Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.9 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.111.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.9.1 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.111.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_registry"></a> [registry](#module\_registry) | ../modules/registry | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.derived_network](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [proxmox_backup_job.crit1](https://registry.terraform.io/providers/bpg/proxmox/0.111.1/docs/resources/backup_job) | resource |
| [proxmox_backup_job.crit2](https://registry.terraform.io/providers/bpg/proxmox/0.111.1/docs/resources/backup_job) | resource |
| [proxmox_backup_job.crit3](https://registry.terraform.io/providers/bpg/proxmox/0.111.1/docs/resources/backup_job) | resource |
| [proxmox_backup_job.crit4](https://registry.terraform.io/providers/bpg/proxmox/0.111.1/docs/resources/backup_job) | resource |
| [proxmox_download_file.rocky9](https://registry.terraform.io/providers/bpg/proxmox/0.111.1/docs/resources/download_file) | resource |
| [proxmox_virtual_environment_pool.crit](https://registry.terraform.io/providers/bpg/proxmox/0.111.1/docs/resources/virtual_environment_pool) | resource |
| [proxmox_virtual_environment_vm.substrate](https://registry.terraform.io/providers/bpg/proxmox/0.111.1/docs/resources/virtual_environment_vm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_inventory_name"></a> [ansible\_inventory\_name](#input\_ansible\_inventory\_name) | The name of the inventory that Ansible will use after this module applies. | `string` | `"protonet"` | no |
| <a name="input_bootstrap_resolver"></a> [bootstrap\_resolver](#input\_bootstrap\_resolver) | The DNS resolver to use before the substrate is built. | `string` | `"9.9.9.9"` | no |
| <a name="input_datastore_id"></a> [datastore\_id](#input\_datastore\_id) | The name of the datastore VM disks should be deployed in. | `string` | `"local-zfs"` | no |
| <a name="input_pbs_storage"></a> [pbs\_storage](#input\_pbs\_storage) | The name of the PBS datastore to use for backups. | `string` | `"pbs-wasabi"` | no |
| <a name="input_rocky9_image_sha256"></a> [rocky9\_image\_sha256](#input\_rocky9\_image\_sha256) | The SHA256 sum of the Rocky9 image. | `string` | n/a | yes |
| <a name="input_rocky9_image_url"></a> [rocky9\_image\_url](#input\_rocky9\_image\_url) | The URL for the Rocky9 image. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
