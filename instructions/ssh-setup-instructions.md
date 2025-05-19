# Setting Up Passwordless Root SSH Between Cluster Nodes

This document outlines the steps to configure passwordless SSH access between Open3FS nodes, which is required for proper cluster operation.

## Manual Setup (Step by Step)

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