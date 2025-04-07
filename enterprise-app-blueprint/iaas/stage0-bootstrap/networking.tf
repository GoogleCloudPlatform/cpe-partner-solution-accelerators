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

locals {
  locations_subnets = flatten([
    for location_key, location in var.sites : [
      for subnet_key, subnet in location.subnets : {
        location_key       = location_key
        location           = location
        subnet_key         = subnet_key
        subnet             = subnet
      }
    ]
  ])

  nat_networks = flatten([
    for network_key, network in var.networks : [
      for nat_region in network.nat_regions : {
        network_key        = network_key
        nat_region         = nat_region
      }
    ]
  ])

  proxy_subnets = flatten([
    for location_key, location in var.sites : {
        location_key       = location_key
        network_key        = location.network
        region             = location.region
        proxy_subnet       = location.proxy_subnet
    }
  ])

  vpc_connector_subnets = flatten([
    for location_key, location in var.sites : {
        location_key       = location_key
        network_key        = location.network
        region             = location.region
        vpc_connector_subnet       = location.vpc_connector_subnet
    }
  ])

}

# Proxy-only subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  for_each = tomap({
    for proxy_subnet in local.proxy_subnets : proxy_subnet.location_key => proxy_subnet
  })

  name          = "proxy-subnet-${each.key}"
  ip_cidr_range = each.value.proxy_subnet
  region        = each.value.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = google_compute_network.vpc_network[each.value.network_key].id
}

# VPC connector subnet
resource "google_compute_subnetwork" "vpc_connector" {
  for_each = tomap({
    for vpc_connector_subnet in local.vpc_connector_subnets : vpc_connector_subnet.location_key => vpc_connector_subnet
  })

  name          = "vpcc-subnet-${each.key}"
  ip_cidr_range = each.value.vpc_connector_subnet
  region        = each.value.region
  network       = google_compute_network.vpc_network[each.value.network_key].id
  private_ip_google_access = true
}

resource "google_compute_network" "vpc_network" {
  for_each                 = var.networks

  name                     = "vpc-${each.key}"
  auto_create_subnetworks  = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  for_each = tomap({
    for subnet in local.locations_subnets : "${subnet.subnet_key}" => subnet
  })

  name          = "vpc-subnetwork-${each.key}"
  region        = each.value.location.region
  network       = google_compute_network.vpc_network[each.value.location.network].id
  private_ip_google_access = true

  ip_cidr_range = each.value.subnet
}

resource "google_compute_router_nat" "nat_egress" {
  for_each = tomap({
    for nat_network in local.nat_networks : "${nat_network.network_key}-${nat_network.nat_region}" => nat_network
  })

  name                               = "nat-egress-${each.value.network_key}-${each.value.nat_region}"
  router                             = google_compute_router.nat_router[each.key].name
  region                             = each.value.nat_region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_external_address[each.key].self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}

resource "google_compute_router" "nat_router" {
  for_each = tomap({
    for nat_network in local.nat_networks : "${nat_network.network_key}-${nat_network.nat_region}" => nat_network
  })

  name    = "router-nat-${each.value.network_key}-${each.value.nat_region}"
  region  = each.value.nat_region
  network = google_compute_network.vpc_network[each.value.network_key].id
  bgp {
    asn = var.nat_bgp_asn
  }
}

resource "google_compute_address" "nat_external_address" {
  for_each = tomap({
    for nat_network in local.nat_networks : "${nat_network.network_key}-${nat_network.nat_region}" => nat_network
  })

  name    = "address-nat-${each.value.network_key}-${each.value.nat_region}"
  region  = each.value.nat_region
}

resource "google_compute_global_address" "psa_ip_alloc" {
  for_each      = var.networks

  name          = "psa-ip-alloc-${each.key}"
  purpose       = "VPC_PEERING"
  address       = var.psa_ip
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network[each.key].id
}

resource "google_service_networking_connection" "default" {
  for_each      = var.networks

  network                 = google_compute_network.vpc_network[each.key].id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa_ip_alloc[each.key].name]
}

resource "google_service_networking_connection" "netapp" {
  for_each      = var.networks

  network                 = google_compute_network.vpc_network[each.key].id
  service                 = "netapp.servicenetworking.goog"
  reserved_peering_ranges = [google_compute_global_address.psa_ip_alloc[each.key].name]
}
