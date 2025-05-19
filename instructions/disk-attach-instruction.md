## Command to Create XFS Filesystem and Mount

To simplify the process, you can use the following script. Copy and paste the entire script into your terminal:

```bash
#!/bin/bash
# Script to create XFS filesystem and mount it

# List block devices to identify the correct device
lsblk

# Replace /dev/sdb with the actual device name if different
DEVICE="/dev/sdb"
MOUNT_POINT="/opt/3fs/storage"

# Create XFS filesystem on the device
sudo mkfs.xfs -f $DEVICE

# Create the mount point directory
sudo mkdir -p $MOUNT_POINT

# Mount the device with appropriate options
sudo mount -o discard,defaults $DEVICE $MOUNT_POINT

# Add entry to /etc/fstab to make the mount persistent across reboots
echo "$DEVICE $MOUNT_POINT xfs discard,defaults 0 2" | sudo tee -a /etc/fstab

# Verify the mount
mount | grep $MOUNT_POINT
```

### Notes
- Replace `/dev/sdb` with the actual device name if it differs.
- Ensure the mount point directory (`/opt/3fs/storage`) is correct and does not conflict with existing directories.