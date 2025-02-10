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

resource "google_compute_firewall" "allow-google-lb-hc-dns" {
  for_each      = var.networks

  name          = "${each.key}-allow-google-lb-hc-dns"

  allow {
    protocol = "all"
  }
  direction     = "INGRESS"
  description   = "Allow Google LoadBalancer HealthChecks and DNS forwarding ranges"
  network       = google_compute_network.vpc_network[each.key].id
  priority      = 1000
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    "35.235.240.0/20",
    "209.85.152.0/22",
    "209.85.204.0/22",
    "35.199.192.0/19"
  ]
}

resource "google_compute_firewall" "allow-google-iap" {
  for_each      = var.networks

  name          = "${each.key}-allow-google-iap"

  allow {
    ports    = ["22", "80", "443", "8080", "8443"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  description   = "Allow Google Identity Aware Proxt (IAP) range - for TCP tunneling"
  network       = google_compute_network.vpc_network[each.key].id
  priority      = 1000
  source_ranges = [
    "35.235.240.0/20"
  ]
}

resource "google_compute_firewall" "allow-internal" {
  for_each      = var.networks

  name          = "${each.key}-allow-internal-rfc1918"

  allow {
    protocol = "all"
  }
  direction     = "INGRESS"
  description   = "Allow rfc1918 ranges"
  network       = google_compute_network.vpc_network[each.key].id
  priority      = 1000
  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "allow-external-http-v4only" {
  for_each      = var.networks

  name          = "${each.key}-allow-external-http-v4only"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "8081", "8443"]
  }
  direction     = "INGRESS"
  description   = "Allow allowlisted external IPv4 ranges"
  network       = google_compute_network.vpc_network[each.key].id
  priority      = 1000
  source_ranges = var.allowlisted_external_ip_ranges_v4only
}

resource "google_compute_firewall" "allow-external-http-v6only" {
  for_each      = var.networks

  name          = "${each.key}-allow-external-http-v6only"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "8081", "8443"]
  }
  direction     = "INGRESS"
  description   = "Allow allowlisred external IPv6 ranges"
  network       = google_compute_network.vpc_network[each.key].id
  priority      = 1000
  source_ranges = var.allowlisted_external_ip_ranges_v6only
}
