terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.35.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
}

resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

#############################################################
#             Private Network with Logging Enabled
#############################################################

resource "google_compute_subnetwork" "private-subnetwork1-with-logging" {
  name          = "public1-log-test-subnetwork"
  ip_cidr_range = "10.1.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "private-subnetwork2-with-logging" {
  name          = "public2-log-test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

#############################################################
#             Public Network with Logging Enabled
#############################################################
resource "google_compute_subnetwork" "public-subnetwork1-with-logging" {
  name          = "private1-log-test-subnetwork"
  ip_cidr_range = "10.11.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
 

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
resource "google_compute_subnetwork" "public-subnetwork2-with-logging" {
  name          = "private2-log-test-subnetwork"
  ip_cidr_range = "10.12.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

#######################################################################################
#                       GOOGLE FIREWALL RULES
#######################################################################################

resource "google_compute_firewall" "rules" {
  project     = var.project_id
  name        = "my-firewall-rule"
  network     = google_compute_network.vpc_network.id
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["80", "8080", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["foo", "bar"]
}


######################## Compute Engine Instance ########################

resource "google_service_account" "desauno" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "standard" {
  name         = "instance-god"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public-subnetwork1-with-logging.self_link

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = file("${path.module}/0-userdata.sh")

#   service_account {
#     # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
#     email  = google_service_account.desauno.email
#     scopes = ["cloud-platform"]
#   }
}


