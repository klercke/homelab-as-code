# Homelab as Code

OpenTofu/Ansible/Shell scripts to build, configure, and manage my homelab.

## Terraform Documentation

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.2 |
| <a name="requirement_linode"></a> [linode](#requirement\_linode) | ~> 2.31.1 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_linode"></a> [linode](#provider\_linode) | 2.31.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [linode_instance.authentik](https://registry.terraform.io/providers/linode/linode/latest/docs/resources/instance) | resource |

### Inputs

No inputs.

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_authentik_server_ip"></a> [authentik\_server\_ip](#output\_authentik\_server\_ip) | The IP assigned to PTXE-LND-AUTH-01 |
<!-- END_TF_DOCS -->

## Ansible Documentation

### Playbooks

| Name | Description |
|------|-------------|
| bootstrap | Applies the bootstrap role |

### Roles

| Name | Description |
|------|-------------|
| bootstrap | Performs basic first-time configuration of a server. Targets Rocky Linux 9, but may work on other distros |

### Inventories

| Name | Description |
|------|-------------|
| linode | Script that automatically generates an inventory from Linode |

## Environment

You will need to define the following environment variables to use this project. I recommend creating a .env file in the root of the project (git will ignore this) and `source`ing it.

```.env
export LINODE_TOKEN=<Linode API Token>
```
