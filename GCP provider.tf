provider "google" {

  credentials = file("/home/ubuntu/GCPInfra/keyfile.json")
  project     = "adept-bison-392015"
  region      = "${var.google_region}"
}
