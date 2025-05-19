# outputs.tf

output "instance_names" {
  description = "Names of the Open3FS compute instances."
  value       = google_compute_instance.open3fs_nodes[*].name
}

output "instance_internal_ips" {
  description = "Internal IP addresses of the Open3FS compute instances."
  value       = google_compute_instance.open3fs_nodes[*].network_interface[0].network_ip
}

output "instance_external_ips" {
  description = "External IP addresses of the Open3FS compute instances."
  value       = google_compute_instance.open3fs_nodes[*].network_interface[0].access_config[0].nat_ip
  // Note: This assumes an external IP is assigned. If an instance had no external IP,
  // access_config[0].nat_ip would be null for that instance.
}

output "data_disk_ids" {
  description = "IDs of the attached data disks."
  value       = google_compute_disk.data_disk[*].self_link // Or .id or .name
}

output "ssh_command_example_node_0" {
  description = "Example SSH command for open3fs-node-0 (replace with your SSH key if needed)."
  value = try(
    "gcloud compute ssh --zone \"${var.gcp_zone}\" \"${google_compute_instance.open3fs_nodes[0].name}\" --project \"${var.gcp_project_id}\"",
    "External IP for node 0 not available or instance not ready."
  )
  // For direct SSH:
  // value = try(
  //   "ssh YOUR_USER@${google_compute_instance.open3fs_nodes[0].network_interface[0].access_config[0].nat_ip}",
  //   "External IP for node 0 not available or instance not ready."
  // )
}

output "ssh_command_example_node_1" {
  description = "Example SSH command for open3fs-node-1 (replace with your SSH key if needed)."
  value = try(
    "gcloud compute ssh --zone \"${var.gcp_zone}\" \"${google_compute_instance.open3fs_nodes[1].name}\" --project \"${var.gcp_project_id}\"",
    "External IP for node 1 not available or instance not ready."
  )
  // For direct SSH:
  // value = try(
  //   "ssh YOUR_USER@${google_compute_instance.open3fs_nodes[1].network_interface[0].access_config[0].nat_ip}",
  //   "External IP for node 1 not available or instance not ready."
  // )
}
