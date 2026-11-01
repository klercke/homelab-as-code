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
roles := "postgres valkey netbox powerdns recursor kea monitoring llm caddy"

default:
    @just --list

# Run the whole pipeline in order
apply: hypervisors substrate base platform playbooks

# 0. Proxmox hosts themselves (zram)
hypervisors *args:
    cd ansible && direnv exec . ansible-playbook playbooks/hypervisors.yml {{ args }}

# 1. Create and resize VMs, regenerate hlac.json
substrate:
    direnv exec terraform/substrate tofu -chdir=terraform/substrate apply

# 2. Base configuration on every VM
base *args:
    cd ansible && direnv exec . ansible-playbook playbooks/base.yml {{ args }}

# 3. NetBox, DNS records, and Kea reservations
platform:
    direnv exec terraform/platform tofu -chdir=terraform/platform apply

# 4. Every role playbook, in order
playbooks:
    for r in {{ roles }}; do just role "$r" || exit 1; done

# Run one role playbook
role name *args:
    cd ansible && direnv exec . ansible-playbook playbooks/{{ name }}.yml {{ args }}

# Preview both Terraform layers without changing anything
plan:
    direnv exec terraform/substrate tofu -chdir=terraform/substrate plan
    direnv exec terraform/platform tofu -chdir=terraform/platform plan

# Publish a new public service from services.yaml
service: substrate platform
    just role caddy --tags config
