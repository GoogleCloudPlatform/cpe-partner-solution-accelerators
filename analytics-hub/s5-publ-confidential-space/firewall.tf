# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     https://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_compute_firewall" "allow-google-lb-hc" {
  name          = "allow-google-lb-hc-${var.name_suffix}"
  project      = google_project.publ_cs_cx_foo_project.name
  network       = google_compute_network.vpc_network.id

  allow {
    ports    = ["22", "80", "443", "8080", "8443"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  description   = "Allow Google LB and HC ranges"
  priority      = 1000
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    "35.235.240.0/20",
    "209.85.152.0/22",
    "209.85.204.0/22"
  ]
}

resource "google_compute_firewall" "allow-google-iap" {
  name          = "allow-google-iap-${var.name_suffix}"
  project      = google_project.publ_cs_cx_foo_project.name
  network       = google_compute_network.vpc_network.id

  allow {
    ports    = ["22", "80", "443", "8080", "8443"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  description   = "Allow Google IAP range"
  priority      = 1000
  source_ranges = [
    "35.235.240.0/20"
  ]
}

resource "google_compute_firewall" "allow-internal" {
  name          = "allow-internal-${var.name_suffix}"
  project      = google_project.publ_cs_cx_foo_project.name
  network       = google_compute_network.vpc_network.id

  allow {
    protocol = "all"
  }
  direction     = "INGRESS"
  description   = "Allow rfc1918 ranges"
  priority      = 1000
  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "allow-external-http" {
  name          = "allow-external-http-${var.name_suffix}"
  project      = google_project.publ_cs_cx_foo_project.name
  network       = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "8081", "8443"]
  }
  direction     = "INGRESS"
  description   = "Allow rfc1918 ranges"
  priority      = 1000
  source_ranges = [
    "0.0.0.0/0",
  ]
}

# Allow outgoing network connectivity to Ubuntu package servers
resource "google_compute_firewall" "egress-allow-required" {
  name    = "egress-allow-required-${var.name_suffix}"
  project      = google_project.publ_cs_cx_foo_project.name
  network       = google_compute_network.vpc_network.id

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  allow {
    protocol = "all"
    ports    = []
  }
  direction     = "EGRESS"
  description   = "Allow required ranges (Ubuntu updates in us-central1)"
  priority      = 999
  source_ranges = [
    "0.0.0.0/0",
  ]
  destination_ranges = [
    "35.184.25.42/32",
    "35.184.34.241/32",
    "35.224.11.34/32",
    "35.202.116.96/32",
    "35.193.225.125/32",
    "35.184.213.5/32",
    "91.189.91.83/32",
    "185.125.190.81/32",
    "91.189.91.82/32",
    "91.189.91.81/32",
    "185.125.190.83/32",
    "185.125.190.82/32",
  ]
}

# Allow access to Google APIs on the restricted VIP (VPC SC)
resource "google_compute_firewall" "egress-allow-googleapis" {
  name    = "egress-allow-googleapis-${var.name_suffix}"
  project      = google_project.publ_cs_cx_foo_project.name
  network       = google_compute_network.vpc_network.id

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  allow {
    protocol = "all"
    ports    = []
  }
  direction     = "EGRESS"
  description   = "Allow access to Google APIs on the restricted VIP (VPC SC)"
  priority      = 998
  source_ranges = [
    "0.0.0.0/0",
  ]
  destination_ranges = [
    "199.36.153.4/32",
    "199.36.153.5/32",
    "199.36.153.6/32",
    "199.36.153.7/32",
  ]
}

# Deny all outgoing network connectivity by default
resource "google_compute_firewall" "egress-deny-all" {
  name    = "egress-deny-all-${var.name_suffix}"
  project      = google_project.publ_cs_cx_foo_project.name
  network       = google_compute_network.vpc_network.id

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
  deny {
    protocol = "all"
    ports    = []
  }
  direction     = "EGRESS"
  description   = "Deny all"
  priority      = 1000
}
