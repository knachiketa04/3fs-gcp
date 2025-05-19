variable "gcp_project_id" {
  description = "The GCP Project ID to deploy resources into."
  type        = string
  default     = "open3fs-3fs-experiment" // Replace with your project ID or set via environment variable/CLI
}

variable "gcp_region" {
  description = "The GCP region to deploy resources into."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" { # Simplified to a single zone
  description = "The GCP zone for all instances."
  type        = string
  default     = "us-central1-c"
}

variable "instance_machine_type" {
  description = "Machine type for the N2 instances."
  type        = string
  default     = "n2-standard-16" # Example: 16 vCPU, 64 GB RAM
}

variable "instance_image_project" {
  description = "The project for the instance image."
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "instance_image_name" {
  description = "Specific OS image name for the instances."
  type        = string
  default     = "ubuntu-2204-jammy-v20250508" # Your specified image
}

variable "instance_names_prefix" {
  description = "Prefix for the instance names. Will create prefix-0, prefix-1, prefix-2."
  type        = string
  default     = "open3fs-node"
}

variable "boot_disk_size_gb" {
  description = "Size of the boot disk in GB."
  type        = number
  default     = 500
}

variable "data_disk_size_gb" {
  description = "Size of the attached data disk in GB."
  type        = number
  default     = 300
}

variable "network_name" {
  description = "Name for the custom VPC network."
  type        = string
  default     = "open3fs-vpc"
}

variable "subnet_name" {
  description = "Name for the subnet in the VPC."
  type        = string
  default     = "open3fs-subnet"
}

variable "subnet_ip_cidr_range" {
  description = "IP CIDR range for the subnet."
  type        = string
  default     = "10.10.0.0/24"
}

variable "allow_ssh_source_ranges" {
  description = "List of IP CIDR ranges to allow SSH from."
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Allows SSH from anywhere. Restrict this in production.
}
