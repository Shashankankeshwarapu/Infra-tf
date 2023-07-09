####Create VPC##########
resource "google_compute_network" "vpc" {
 name                    = "samplevpc"
 auto_create_subnetworks = "false"
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
  network = google_compute_network.vpc.name

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
  #allow_stopping_for_update = true

    boot_disk {
    initialize_params {
   #   image = "Ubuntu 20.04 LTS"
       image = "ubuntu-os-cloud/ubuntu-2004-lts"

    }
    }

    network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
    access_config {}
       }
   }

resource "google_container_cluster" "primary" {
  description  = "GKE Cluster for sample project"
  name     = "sample-gke-cluster"
  location = "us-central1"
  network  = google_compute_network.vpc.name
  remove_default_node_pool = true
  initial_node_count       = 1
  subnetwork               = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "primary" {
  name       = "sample-node-pool"
  cluster    = google_container_cluster.primary.id
  node_count = 1
  node_locations = [
    "us-central1-b", "us-central1-c"
  ]
     

  node_config {
    #preemptible  = false
    machine_type = "e2-medium"

  }
}
