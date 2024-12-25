#!/usr/bin/env python3

import requests
import os
import json

# Fetch the Linode API token from an environment variable
LINODE_API_TOKEN = os.getenv("LINODE_TOKEN")

if not LINODE_API_TOKEN:
    raise ValueError("Please set the LINODE_API_TOKEN environment variable.")

# Linode API endpoint
LINODE_API_URL = "https://api.linode.com/v4/linode/instances"

def fetch_linode_instances():
    """Fetch details of all Linode instances using the API."""
    headers = {
        "Authorization": f"Bearer {LINODE_API_TOKEN}",
        "Content-Type": "application/json",
    }
    response = requests.get(LINODE_API_URL, headers=headers)
    response.raise_for_status()
    return response.json()["data"]

def build_inventory(instances):
    """Build the inventory dictionary."""
    inventory = {"all": {"hosts": []}, "_meta": {"hostvars": {}}}

    for instance in instances:
        hostname = instance["label"]
        ip_address = instance["ipv4"][0]  # Primary IPv4 address
        group = instance["tags"][0] if instance["tags"] else "ungrouped"

        # Add host to the "all" group
        inventory["all"]["hosts"].append(hostname)

        # Add host-specific variables
        inventory["_meta"]["hostvars"][hostname] = {
            "ansible_host": ip_address,
            "region": instance["region"],
            "status": instance["status"],
            "tags": instance["tags"],
        }

        # Add host to its tag-based group
        if group not in inventory:
            inventory[group] = {"hosts": []}
        inventory[group]["hosts"].append(hostname)

    return inventory

if __name__ == "__main__":
    try:
        instances = fetch_linode_instances()
        inventory = build_inventory(instances)
        print(json.dumps(inventory, indent=2))
    except Exception as e:
        print(json.dumps({"_meta": {"hostvars": {}}}, indent=2))
        print(f"Error: {e}")

