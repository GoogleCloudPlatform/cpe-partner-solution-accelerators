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
  project                 = data.google_project.prov_seed_project.project_id
  name                    = "vpc-${var.name_suffix}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  project       = data.google_project.prov_seed_project.project_id
  name          = "vpc-subnetwork-${var.name_suffix}"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = true

  ip_cidr_range = var.subnet_cidr
}

resource "google_compute_router" "nat_router" {
  project      = data.google_project.prov_seed_project.project_id
  name    = "router-nat-${var.name_suffix}"
  region  = var.region
  network = google_compute_network.vpc_network.id
  bgp {
    asn = var.nat_bgp_asn
  }
}

resource "google_compute_address" "nat_external_address" {
  project      = data.google_project.prov_seed_project.project_id
  name    = "address-nat-${var.name_suffix}"
  region  = var.region
}

resource "google_compute_router_nat" "nat_egress" {
  project      = data.google_project.prov_seed_project.project_id
  name                               = "nat-egress-${var.name_suffix}"

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
  project      = data.google_project.prov_seed_project.project_id
  peering = google_service_networking_connection.default.peering
  network = google_compute_network.vpc_network.name

  import_custom_routes = true
  export_custom_routes = true
}

resource "google_compute_global_address" "private_ip_alloc" {
  project      = data.google_project.prov_seed_project.project_id
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address       = var.psa_ip
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}
