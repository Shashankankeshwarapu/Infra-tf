####Create VPC##########
resource "google_compute_network" "vpc" {
  project                 = "adept-bison-392015"
  name                    = "samplevpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

#####Create Subnet############
resource "google_compute_subnetwork" "subnet" {
 name          = "samplesubnet"
 ip_cidr_range = "10.0.0.0/16"
 network       = "samplevpc"
 depends_on    = [google_compute_network.vpc]
 region      = "${var.google_region}"
}

#####VPC firewall configuration####
resource "google_compute_firewall" "firewall" {
  name    = "samplefirewall"
  network = "samplevpc"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
 }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["generalaccess"]
}

resource "google_compute_instance" "default" {
  name         = "sampleinstance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

    boot_disk {
    initialize_params {
      image = "Ubuntu 20.04 LTS"
      }
  }
}

network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
