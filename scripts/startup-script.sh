#!/bin/bash
# Startup script for Open3FS nodes
set -e

# Log startup
echo "Starting instance setup at $(date)" > /var/log/startup-script.log

# Update package lists
sudo apt-get update -y >> /var/log/startup-script.log 2>&1

# RXE Module Installation
echo "Installing RXE modules..." >> /var/log/startup-script.log
sudo apt-get install linux-modules-extra-$(uname -r) -y >> /var/log/startup-script.log 2>&1
sudo modprobe rdma_rxe >> /var/log/startup-script.log 2>&1

# Make RXE module load on boot
echo "rdma_rxe" | sudo tee -a /etc/modules-load.d/rdma_rxe.conf

# Docker Installation
echo "Installing Docker..." >> /var/log/startup-script.log

## Uninstall old versions
echo "Removing old Docker versions..." >> /var/log/startup-script.log
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
  sudo apt-get remove -y $pkg >> /var/log/startup-script.log 2>&1
done

## Install using the apt repository
echo "Adding Docker repository..." >> /var/log/startup-script.log
sudo apt-get install -y ca-certificates curl >> /var/log/startup-script.log 2>&1
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

## Add the repository to Apt sources
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y >> /var/log/startup-script.log 2>&1

## Install Docker packages
echo "Installing Docker packages..." >> /var/log/startup-script.log
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> /var/log/startup-script.log 2>&1

## Test Docker installation
echo "Testing Docker installation..." >> /var/log/startup-script.log
sudo docker run hello-world >> /var/log/startup-script.log 2>&1

# Log completion
echo "Startup script completed at $(date)" >> /var/log/startup-script.log