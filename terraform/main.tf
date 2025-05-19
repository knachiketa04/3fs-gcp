# main.tf

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# -------------------------------------
# Network Resources
# -------------------------------------

resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false      # We will create a custom subnet
  routing_mode            = "REGIONAL" # For regional dynamic routing
  mtu                     = 1460       # Standard MTU, can be 1500 for N2 if jumbo frames are not used, or higher for jumbo frames.
  # RXE (Soft-RoCE) might benefit from Jumbo Frames (e.g., 9000 MTU),
  # but this requires OS-level config as well. For now, 1460 is safe.
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_cidr_range
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id # Links to the VPC created above

  private_ip_google_access = true # Allows instances without external IPs to reach Google APIs
}

# -------------------------------------
# Firewall Rules
# -------------------------------------

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc_network.id # Correctly references the existing network
  project = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allow_ssh_source_ranges
  target_tags   = ["open3fs-node"] # We will add this tag to our instances
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc_network.id # Correctly references the existing network
  project = var.gcp_project_id

  allow {
    protocol = "all" # Allows all protocols (tcp, udp, icmp)
  }

  source_tags = ["open3fs-node"] # Allows traffic from any instance with this tag
  target_tags = ["open3fs-node"] # To any instance with this tag
}

resource "google_compute_firewall" "allow_icmp_internal" {
  name    = "${var.network_name}-allow-icmp-internal"
  network = google_compute_network.vpc_network.id # Correctly references the existing network
  project = var.gcp_project_id

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_ip_cidr_range] # Allow ICMP from within our subnet
  target_tags   = ["open3fs-node"]
}


# -------------------------------------
# Compute Instances
# -------------------------------------

resource "google_compute_instance" "open3fs_nodes" {
  count        = 3
  project      = var.gcp_project_id
  zone         = var.gcp_zone # Use the single zone variable
  name         = "${var.instance_names_prefix}-${count.index + 1}"  # Node Count starts from 1
  machine_type = var.instance_machine_type
  tags         = ["open3fs-node", var.network_name]

  boot_disk {
    initialize_params {
      image = "projects/${var.instance_image_project}/global/images/${var.instance_image_name}" # Construct full image path
      size  = var.boot_disk_size_gb
      type  = "pd-balanced"
    }
  }

  attached_disk {
    source      = google_compute_disk.data_disk[count.index].name
    device_name = "data-disk-0" # Device name inside the OS
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet.id
    network_ip = "10.10.0.${count.index + 11}"  # Assign specific IPs: 10.10.0.11, 10.10.0.12, 10.10.0.13
    access_config {} # To assign an ephemeral public IP (default behavior)
  }

  # Add startup script from file
  metadata = {
    startup-script = file("${path.module}/scripts/startup-script.sh")
  }

  allow_stopping_for_update = true
}

# -------------------------------------
# Attached Data Disks
# -------------------------------------

resource "google_compute_disk" "data_disk" {
  count   = 3
  project = var.gcp_project_id
  zone    = var.gcp_zone # Data disk must be in the same zone as the instance
  name    = "${var.instance_names_prefix}-data-disk-${count.index + 1}"  # Start from 1 instead of 0
  type    = "pd-balanced"
  size    = var.data_disk_size_gb
}