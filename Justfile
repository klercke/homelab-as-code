# Order of operations for applying changes. See README.md.
#
#   just                           list recipes
#   just apply                     run everything, in order
#   just role llm                  run a single role playbook
#   just base --limit netbox01     extra args pass through to ansible-playbook
#
# Each directory's .envrc holds its own credentials, so every recipe runs
# through `direnv exec` in that directory instead of relying on the shell.

# Role playbooks, in dependency order
roles := "postgres valkey netbox powerdns recursor kea monitoring llm immich caddy pbs"

default:
    @just --list

# Run the whole pipeline in order
apply: hypervisors substrate base platform firewall playbooks inventory

# 0. Proxmox hosts themselves (zram)
hypervisors *args:
    cd ansible && direnv exec . ansible-playbook playbooks/hypervisors.yml {{ args }}

# 1. Create and resize VMs, regenerate hlac.json
substrate:
    direnv exec terraform/substrate tofu -chdir=terraform/substrate apply

# 2. Base configuration on every VM
base *args:
    cd ansible && direnv exec . ansible-playbook playbooks/base.yml {{ args }}

# 3. DNS records and Kea reservations
platform:
    direnv exec terraform/platform tofu -chdir=terraform/platform apply

# 3b. Host and role aliases on fw01
firewall:
    direnv exec terraform/firewall tofu -chdir=terraform/firewall apply

# 4. Every role playbook, in order
playbooks:
    for r in {{ roles }}; do just role "$r" || exit 1; done

# 5. Record everything in NetBox
inventory:
    direnv exec terraform/inventory tofu -chdir=terraform/inventory apply

# Run one role playbook
role name *args:
    cd ansible && direnv exec . ansible-playbook playbooks/{{ name }}.yml {{ args }}

# Preview every Terraform layer without changing anything
plan:
    direnv exec terraform/substrate tofu -chdir=terraform/substrate plan
    direnv exec terraform/platform tofu -chdir=terraform/platform plan
    direnv exec terraform/firewall tofu -chdir=terraform/firewall plan
    direnv exec terraform/inventory tofu -chdir=terraform/inventory plan

# Publish a new public service from services.yaml
service: substrate platform
    just role caddy --tags config

# Build an unattended installer ISO for a physical host
# just iso pbs01 /path/to/pbs.io OR
# just iso pbs01 /path/to/pbs.io --burn
iso host source_iso *args:
    scripts/build-installer-iso.sh {{ args }} {{ host }} {{ source_iso }}
