#!/bin/bash

# Path to your inventory file or dynamic inventory script
INVENTORY="ansible/inventories/production"

# Extract ansible_host values from the inventory
HOSTS=$(ansible-inventory -i $INVENTORY --list | jq -r '._meta.hostvars | to_entries[] | .value.ansible_host')

# Add each host's SSH key to known_hosts
for HOST in $HOSTS; do
    echo "Adding SSH key for host: $HOST"
    ssh-keyscan -H "$HOST" >> ~/.ssh/known_hosts 2>/dev/null
done

echo "All host keys have been added to ~/.ssh/known_hosts."

