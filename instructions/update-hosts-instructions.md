# Updating /etc/hosts on Each Node

This file provides a sample script to update the `/etc/hosts` file on each node in the cluster to ensure proper hostname resolution.

## Sample Script

```bash
#!/bin/bash
# Update /etc/hosts for Open3FS cluster

# Define the IPs and hostnames of the nodes
cat <<EOL | sudo tee -a /etc/hosts
10.10.0.11 open3fs-node-1
10.10.0.12 open3fs-node-2
10.10.0.13 open3fs-node-3
EOL

# Verify the changes
cat /etc/hosts
```

## Instructions

1. Copy the above script to a file, e.g., `update-hosts.sh`.
2. Transfer the script to each node in the cluster.
3. Run the script on each node as root:
   ```bash
   sudo bash update-hosts.sh
   ```
4. Verify that the `/etc/hosts` file has been updated correctly on all nodes.