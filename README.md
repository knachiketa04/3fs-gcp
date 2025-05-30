# DeepSeek 3FS on Google Cloud Platform for app dev/testing (RXE: Software RDMA over Ethernet/ Soft-RoCE Based)  
This repository contains Terraform scripts and configuration files to deploy a DeepSeek 3FS cluster on Google Cloud Platform, following the [DeepSeek 3FS non-RDMA installation guide](https://blog.open3fs.com/2025/04/01/deepseek-3fs-non-rdma-install-faster-ecosystem-app-dev-testing.html).

## Overview

DeepSeek 3FS is a high-performance distributed file system optimized for AI workloads. This setup creates a 3-node cluster on GCP with the necessary configuration for running 3FS without specialized RDMA hardware, using the RXE (RDMA over Ethernet) module instead.

## Infrastructure Components

This Terraform configuration creates:

- Custom VPC network and subnet
- 3 GCP Compute Engine instances (n2-standard-16 by default)
- Attached data disks for 3FS storage
- Appropriate firewall rules for internal cluster communication
- RXE (RDMA over Ethernet) configuration

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/install) (v1.0.0+)
- A Google Cloud Platform account with appropriate permissions
- Service account with necessary permissions:
  - Compute Admin
  - Storage Admin
  - Network Admin

## Deployment Instructions

### 1. Clone this repository

```bash
git clone https://github.com/yourusername/3fs-gcp.git
cd 3fs-gcp
```

### 2. Navigate to the Terraform folder

```bash
cd terraform
```

### 3. Configure your GCP project

Update the [`variables.tf`](terraform/variables.tf) file or create a `terraform.tfvars` file to override defaults:

```hcl
gcp_project_id = "your-gcp-project-id"
gcp_region     = "preferred-region"
gcp_zone       = "preferred-zone"
```

### 4. Initialize and apply the Terraform configuration

```bash
terraform init
terraform plan
terraform apply
```

### 5. Post-Deployment Steps

After the infrastructure is deployed, complete the following steps:

#### 5.1 Set up passwordless SSH

Follow the instructions in [`ssh-setup-instructions.md`](instructions/ssh-setup-instructions.md) to configure passwordless SSH between the cluster nodes, which is required for 3FS operation.

#### 5.2 Prepare the data disks

On each node, follow the instructions in [`disk-attach-instruction.md`](instructions/disk-attach-instruction.md) to format the attached data disks and mount them to `/opt/3fs/storage`.

#### 5.3 Update /etc/hosts

Follow the instructions in [`update-hosts-instructions.md`](instructions/update-hosts-instructions.md) to update the `/etc/hosts` file on each node. This ensures proper hostname resolution within the cluster.

#### 5.4 Deploy DeepSeek 3FS

Update the IP addresses in the [`cluster.yml`](cluster.yml) file if they differ from the default configuration (`10.10.0.11`, `10.10.0.12`, `10.10.0.13`). Then follow the DeepSeek 3FS deployment instructions from the [official guide](https://blog.open3fs.com/2025/04/01/deepseek-3fs-non-rdma-install-faster-ecosystem-app-dev-testing.html).

## Configuration Files

- [`terraform/variables.tf`](terraform/variables.tf): Contains all configurable parameters for the deployment
- [`terraform/main.tf`](terraform/main.tf): Main Terraform configuration defining GCP resources
- [`terraform/outputs.tf`](terraform/outputs.tf): Defines outputs after deployment, including IP addresses
- [`terraform/versions.tf`](terraform/versions.tf): Specifies Terraform and provider version requirements
- [`scripts/startup-script.sh`](scripts/startup-script.sh): Script that runs on instance startup to configure RXE and Docker
- [`cluster.yml`](cluster.yml): 3FS cluster configuration
- [`instructions/ssh-setup-instructions.md`](instructions/ssh-setup-instructions.md): Instructions for setting up SSH keys
- [`instructions/disk-attach-instruction.md`](instructions/disk-attach-instruction.md): Instructions for formatting and mounting data disks
- [`instructions/update-hosts-instructions.md`](instructions/update-hosts-instructions.md): Instructions for updating host files

## Customization Options

You can customize various aspects of the deployment by modifying variables in [`terraform/variables.tf`](terraform/variables.tf) or by creating a `terraform.tfvars` file:

- `instance_machine_type`: VM size (default: n2-standard-16)
- `boot_disk_size_gb`: Boot disk size (default: 200GB)
- `data_disk_size_gb`: Data disk size (default: 500GB)
- `gcp_region` and `gcp_zone`: Geographical location for resources

## Destroying the Environment

To tear down the environment:

```bash
terraform destroy
```

## Security Notes

- The default configuration allows SSH access from any IP (`0.0.0.0/0`). For production use, restrict this to your IP address or VPN range.
- Consider implementing additional security measures for production deployments.

## Fio Test with USRBIO Engine

Once your 3FS cluster is deployed and running, you can perform I/O performance testing using fio with the USRBIO engine. This test will validate the performance of the 3FS filesystem:

```bash
docker exec -it 3fs-client fio -numjobs=1 -fallocate=none -ioengine=external:/usr/lib/hf3fs_usrbio.so -direct=1 -rw=read -bs=4MB -group_reporting -size=200MB -time_based -runtime=300 -iodepth=1 -name=/mnt/3fs/test0 -mountpoint=/mnt/3fs
```

This command will:
- Run a single job (`-numjobs=1`)
- Use the 3FS USRBIO engine (`-ioengine=external:/usr/lib/hf3fs_usrbio.so`)
- Perform direct I/O (`-direct=1`)
- Execute read operations (`-rw=read`)
- Use 4MB block size (`-bs=4MB`)
- Run for 300 seconds (`-runtime=300`)
- Test with a 200MB file size (`-size=200MB`)
- Use the 3FS mount point (`-mountpoint=/mnt/3fs`)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Related Projects

- [open3fs/m3fs](https://github.com/open3fs/m3fs): m3fs(Make 3FS) is the toolset designed to manage 3FS cluster.  

## License

This repository is licensed under the [MIT License](LICENSE).