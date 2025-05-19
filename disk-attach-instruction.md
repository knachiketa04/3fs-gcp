## Command to cretae xfs filesystem and mount
```bash
1. lsblk
2. sudo mkfs.xfs -f /dev/sdb # (change /dev/sdb with the actual device)
3. sudo mkdir -p /opt/3fs/storage
4. sudo mount -o discard,defaults /dev/sdb /opt/3fs/storage
```

To make this permanent across reboots, add an entry to `/etc/fstab`:
```bash
echo '/dev/sdb /opt/3fs/storage xfs discard,defaults 0 2' | sudo tee -a /etc/fstab
```