# Homelab as Code

OpenTofu/Ansible/Shell scripts to build, configure, and manage my homelab.

This repository is hosted on [GitLab](https://gitlab.com/klercke/homelab-as-code) and mirrored to [GitHub](https://github.com/klercke/homelab-as-code).
All development is done in the GitLab repository.

## Terraform Documentation

Terraform documentation is within the submodules in the `terraform/` directory.

## Ansible Documentation

Ansible documentation is within the `ansible/` directory.

## Order of Operations

Operations should always be done in the following order:
1. Apply Terraform substrate
2. Run Ansible base playbook
3. Apply Terraform platform
4. Run Ansible role playbooks

## TODO

These are features that I intend to add in the future.

- [x] IPv6 for clients, DNS, public services, and VMs
- [ ] IPv6 for backends (drop IPv4 between services)
- [ ] Every host creates an alias in the firewall
- [ ] Kubernetes for workloads
- [ ] CI/CD to lint and deploy
- [ ] Automatically generate diagrams from registry
- [ ] HA Postgres
- [ ] Identity Provider
- [ ] Firewall/switch management(?)
