#!/usr/bin/env python3

import subprocess
import os
import sys

ENVIRONMENT_TAG = "staging"

# Gross
wrapper_dir = os.path.dirname(os.path.abspath(__file__))
inventory_script = os.path.join(wrapper_dir, "../../../scripts/linode_inventory.py")

# Call the inventory script and return its output
try:
    result = subprocess.run(
        [sys.executable, inventory_script, ENVIRONMENT_TAG],
        check=True,
        capture_output=True,
        text=True,
    )
    # Ensure stdout contains only valid JSON
    sys.stdout.write(result.stdout)
    sys.exit(0)
except subprocess.CalledProcessError as e:
    sys.stderr.write(e.stderr)  # Write error to stderr for debugging
    sys.exit(e.returncode)
    
