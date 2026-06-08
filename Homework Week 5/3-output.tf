output "instance_ip" {
  value = "http:${google_compute_instance.standard.network_interface[0].access_config[0].nat_ip}"
  description = "The external IP address of the Compute Engine instance."
}