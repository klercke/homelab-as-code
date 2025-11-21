# Homelab as Code

OpenTofu/Ansible/Shell scripts to build, configure, and manage my homelab.

This repository is hosted on [GitLab](https://gitlab.com/klercke/homelab-as-code) and mirrored to [GitHub](https://github.com/klercke/homelab-as-code).
All development is done in the GitLab repository.

## Terraform Documentation

<!-- BEGIN_TF_DOCS -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.2 |
| <a name="requirement_linode"></a> [linode](#requirement\_linode) | ~> 2.31.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5.2 |
| <a name="requirement_njalla"></a> [njalla](#requirement\_njalla) | ~> 0.10.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_linode"></a> [linode](#provider\_linode) | 2.31.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |
| <a name="provider_njalla"></a> [njalla](#provider\_njalla) | 0.10.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [linode_instance.authentik](https://registry.terraform.io/providers/linode/linode/latest/docs/resources/instance) | resource |
| [linode_instance.monitoring](https://registry.terraform.io/providers/linode/linode/latest/docs/resources/instance) | resource |
| [local_file.mon_hostvars](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [njalla_record_a.auth](https://registry.terraform.io/providers/Sighery/njalla/latest/docs/resources/record_a) | resource |
| [njalla_record_a.mon](https://registry.terraform.io/providers/Sighery/njalla/latest/docs/resources/record_a) | resource |

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
| docker | Applies the bootstrap role and the docker role |
| update | Applies the update role |
| caddy | Applies the bootstrap, docker, and caddy roles |

### Roles

| Name | Description |
|------|-------------|
| bootstrap | Performs basic first-time configuration of a server. Targets Rocky Linux 9, but may work on other distros |
| docker | Adds the docker repo to a Rocky 9 server, installs docker-ce, and starts the docker service |
| update | Updates all packages on the host |
| caddy | Installs Caddy server and creates a simple landing page with TLS |

### Inventories

| Name | Description |
|------|-------------|
| {production,staging}/linode | Script that automatically generates an inventory from Linode based on tags |

## Environment

You will need to define the following environment variables to use this project. I recommend creating a .env file in the root of the project (git will ignore this) and `source`ing it.

```.env
export LINODE_TOKEN=<Linode API Token>
export NJALLA_API_TOKEN=<Njalla API Token>
```

### Token Permissions

- **LINODE_TOKEN** requires the following permissions:
    - Untested, I gave it full read/write (oops)
- **NJALLA_API_TOKEN** requires the following permissions on the domain you want to manage:
    - list-records
    - add-record
    - edit-record
    - remove-record
