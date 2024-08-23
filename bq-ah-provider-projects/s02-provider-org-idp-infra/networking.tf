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

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-${random_string.suffix.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "vpc-subnetwork-${random_string.suffix.result}"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true

  ip_cidr_range = var.subnet_cidr
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "vpc-subnetwork-gke-${random_string.suffix.result}"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true

  ip_cidr_range = var.gke_subnet_cidr

  dynamic "secondary_ip_range" {
    for_each = var.gke_clusters
    content {
      range_name    = "${secondary_ip_range.key}-pods"
      ip_cidr_range = "${secondary_ip_range.value.pod_range}"
    }
  }

  dynamic "secondary_ip_range" {
    for_each = var.gke_clusters
    content {
      range_name    = "${secondary_ip_range.key}-services"
      ip_cidr_range = "${secondary_ip_range.value.service_range}"
    }
  }
}

resource "google_compute_router" "nat_router" {
  name    = "router-nat-${var.region}-${random_string.suffix.result}"
  region  = var.region
  network = google_compute_network.vpc_network.id
  bgp {
    asn = var.nat_bgp_asn
  }
}

resource "google_compute_address" "nat_external_address" {
  name    = "address-nat-${var.region}-${random_string.suffix.result}"
  region  = var.region
}

resource "google_compute_router_nat" "nat_egress" {
  name                               = "nat-egress-${var.region}-${random_string.suffix.result}"

  router                             = google_compute_router.nat_router.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_external_address.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}

resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering = google_service_networking_connection.default.peering
  network = google_compute_network.vpc_network.name

  import_custom_routes = true
  export_custom_routes = true
}
