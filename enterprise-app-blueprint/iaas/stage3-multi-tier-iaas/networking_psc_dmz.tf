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
  psc_subnets = flatten([
    for location_key, location in var.sites : {
        location_key       = location_key
        network_key        = location.network
        region             = location.region
        psc_subnet         = location.psc_subnet
    }
  ])
}


# Proxy-only subnet
resource "google_compute_subnetwork" "psc_subnet" {
  for_each = tomap({
    for psc_subnet in local.psc_subnets : psc_subnet.location_key => psc_subnet
  })

  name          = "psc-subnet-${each.key}"
  ip_cidr_range = each.value.psc_subnet
  region        = each.value.region
  network       = data.google_compute_network.vpc_network[each.value.network_key].id
  private_ip_google_access = true
  purpose                  = "PRIVATE_SERVICE_CONNECT"
}

resource "google_compute_service_attachment" "l7-rilb-site1" {
  name                  = "l7-rilb-site1"
  region                = var.sites["fra"].region
  reconcile_connections = true
  enable_proxy_protocol = false
  target_service        = google_compute_forwarding_rule.l7-rilb-site1.id
  nat_subnets           = [
    google_compute_subnetwork.psc_subnet["fra"].id
  ]

  connection_preference = "ACCEPT_MANUAL"
#  connection_preference = "ACCEPT_AUTOMATIC"
  consumer_accept_lists {
    connection_limit = 10
    network_url      = data.google_compute_network.vpc_network["dmz"].self_link
  }
}

# IP Address
resource "google_compute_address" "dmz-webtier-site1-lb-endpoint" {
  name         = "dmz-webtier-site1-lb-endpoint"
  region       = var.sites["fra-dmz"].region
  subnetwork   = data.google_compute_subnetwork.vpc_subnet["fra-dmz-webtier"].id
  address_type = "INTERNAL"
}

# PSC endpoint
resource "google_compute_forwarding_rule" "consumer_endpoint" {
  name                    = "dmz-webtier-site1-lb-endpoint"
  region                  = var.sites["fra-dmz"].region
  network                 = data.google_compute_network.vpc_network["dmz"].id
  ip_address              = google_compute_address.dmz-webtier-site1-lb-endpoint.id
  target                  = google_compute_service_attachment.l7-rilb-site1.id
  load_balancing_scheme   = "" # Explicit empty string required for PSC
  allow_psc_global_access = true
}

resource "google_dns_record_set" "dmz-webtier-site1-lb-endpoint" {
  name         = "site1psc.${var.dns_custom_domain}"
  managed_zone = data.google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_address.dmz-webtier-site1-lb-endpoint.address ]
}
