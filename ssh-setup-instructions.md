# Setting Up Passwordless Root SSH Between Cluster Nodes

This document outlines the steps to configure passwordless SSH access between Open3FS nodes, which is required for proper cluster operation.

## Option 1: Manual Setup (Step by Step)

### On Each Node:

1. Become root:
   ```bash
   sudo -i
   ```

2. Generate SSH key (if not existing):
   ```bash
   [ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
   ```

3. Configure SSH daemon to allow root login with keys:
   ```bash
   # Edit SSH config properly using sed instead of manual editing
   sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
   sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
   # Only enable password authentication temporarily if needed
   sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
   
   # Restart SSH service
   systemctl restart sshd
   ```

4. Ensure proper SSH directory permissions:
   ```bash
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   touch ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

5. Display your public key:
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```

6. Copy the output of the above command.

7. On each of the OTHER nodes, add the copied public key to the authorized_keys file:
   ```bash
   echo "PASTE_COPIED_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
   ```

8. Test the connection from each node to every other node:
   ```bash
   ssh -o StrictHostKeyChecking=no root@open3fs-node-1
   ssh -o StrictHostKeyChecking=no root@open3fs-node-2
   ssh -o StrictHostKeyChecking=no root@open3fs-node-3
   ```

## Option 2: Automated Setup (Recommended)

Create a script on one node (e.g., open3fs-node-1) to automate the key distribution:

```bash
#!/bin/bash
# Script: setup-ssh-keys.sh

# Define node information (use actual IPs from your environment)
NODES=("open3fs-node-1" "open3fs-node-2" "open3fs-node-3")
IPS=("10.10.0.11" "10.10.0.12" "10.10.0.13")

# Must run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
fi

# Configure SSH on all nodes
for ((i=0; i<${#NODES[@]}; i++)); do
    NODE=${NODES[$i]}
    IP=${IPS[$i]}
    
    echo "Setting up SSH on $NODE ($IP)..."
    
    # SSH configuration (accepts key-based root login)
    ssh -o StrictHostKeyChecking=no root@$IP "
        sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
        sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        systemctl restart sshd
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        touch ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    " || { echo "Failed to configure SSH on $NODE"; continue; }
    
    # Copy our public key to the node
    cat ~/.ssh/id_rsa.pub | ssh -o StrictHostKeyChecking=no root@$IP "cat >> ~/.ssh/authorized_keys"
    
    echo "Setup completed for $NODE"
done

# Verify SSH connectivity
echo "Testing SSH connectivity..."
for NODE in "${NODES[@]}"; do
    echo -n "Connecting to $NODE: "
    ssh -o StrictHostKeyChecking=no -o BatchMode=yes root@$NODE "echo Success"
done

# Secure the setup - disable password authentication after setup is complete
echo "Securing SSH configuration..."
for ((i=0; i<${#NODES[@]}; i++)); do
    IP=${IPS[$i]}
    ssh -o StrictHostKeyChecking=no root@$IP "
        sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        systemctl restart sshd
    "
done

echo "SSH setup complete. All nodes should now have passwordless root SSH access."
```

Save this as `setup-ssh-keys.sh`, make it executable with `chmod +x setup-ssh-keys.sh`, and run it on your first node.

## Security Note

After completing SSH setup, it's recommended to:

1. Disable password authentication by setting `PasswordAuthentication no` in `/etc/ssh/sshd_config`
2. Consider restricting root login to key-based only with `PermitRootLogin prohibit-password` 
3. Restart the SSH service after making these changes

## Troubleshooting

1. If you get permission denied errors:
   - Verify the permissions on ~/.ssh and ~/.ssh/authorized_keys (700 and 600)
   - Check sshd_config settings
   - Look at logs with `journalctl -u sshd`

2. If host key verification fails:
   - You can bypass initially with `ssh -o StrictHostKeyChecking=no`
   - Or clear problematic keys: `ssh-keygen -R hostname_or_ip`