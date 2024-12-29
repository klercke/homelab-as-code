#!/usr/bin/env python3

import requests
import os
import json

# Fetch the Linode API token from an environment variable
LINODE_API_TOKEN = os.getenv("LINODE_TOKEN")

# Set the environment tag. We will only build an inventory from Linodes with
# this tag set
ENVIRONMENT_TAG = "prod"

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
        # Skip VMs that are not in this environment
        if not ENVIRONMENT_TAG in instance["tags"]:
            continue

        # Basic Linode info
        hostname = instance["label"]
        ip_address = instance["ipv4"][0] if instance["ipv4"] else None  # Handle empty IPv4 list

        # Add host to the "all" group
        inventory["all"]["hosts"].append(hostname)

        # Add host-specific variables
        inventory["_meta"]["hostvars"][hostname] = {
            "ansible_host": ip_address,
            "region": instance["region"],
            "status": instance["status"],
            "tags": instance["tags"],
        }

        # Add host to all non-ENVIRONMENT_TAG tag-based groups
        for tag in instance["tags"]:
            if tag == ENVIRONMENT_TAG:
                continue
            if tag not in inventory:
                inventory[tag] = {"hosts": []}
            inventory[tag]["hosts"].append(hostname)

    return inventory

if __name__ == "__main__":
    try:
        instances = fetch_linode_instances()
        inventory = build_inventory(instances)
        print(json.dumps(inventory, indent=2))
    except Exception as e:
        print(json.dumps({"_meta": {"hostvars": {}}}, indent=2))
        print(f"Error: {e}")

