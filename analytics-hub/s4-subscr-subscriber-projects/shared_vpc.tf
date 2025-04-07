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

resource "google_compute_network" "vpc_network_xpn" {
  project      = data.google_project.subscr_subscr_xpn.name
  name                    = "vpc-xpn-${var.name_suffix}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet_xpn" {
  project      = data.google_project.subscr_subscr_xpn.name
  name          = "vpc-xpn-subnetwork-${var.name_suffix}"
  region        = var.region
  network       = google_compute_network.vpc_network_xpn.id
  private_ip_google_access = true

  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_router" "nat_router_xpn" {
  project      = data.google_project.subscr_subscr_xpn.name
  name    = "router-nat-${var.name_suffix}"
  region  = var.region
  network = google_compute_network.vpc_network_xpn.id
  bgp {
    asn = 64514
  }
}

resource "google_compute_address" "nat_external_address_xpn" {
  project      = data.google_project.subscr_subscr_xpn.name
  name    = "address-nat-${var.name_suffix}"
  region  = var.region
}

resource "google_compute_router_nat" "nat_egress_xpn" {
  project      = data.google_project.subscr_subscr_xpn.name
  name                               = "nat-egress-${var.name_suffix}"

  router                             = google_compute_router.nat_router_xpn.name
  region                             = var.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat_external_address_xpn.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    filter = "TRANSLATIONS_ONLY"
    enable = true
  }
}

resource "google_compute_shared_vpc_host_project" "host" {
  project = data.google_project.subscr_subscr_xpn.name
}

resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = data.google_project.subscr_subscr_xpn.name
  service_project = data.google_project.subscr_subscr_vm.name
}

data "google_compute_default_service_account" "default_xpn" {
  project      = data.google_project.subscr_subscr_xpn.name
}

data "google_compute_default_service_account" "default_vm" {
  project      = data.google_project.subscr_subscr_vm.name
}

output "default_account_vm" {
  value = data.google_compute_default_service_account.default_vm.email
}

output "default_account_xpn" {
  value = data.google_compute_default_service_account.default_xpn.email
}

resource "google_compute_instance" "jumphost_in_xpn" {
  project      = data.google_project.subscr_subscr_xpn.name
  zone         = var.zone
  name         = "jumphost-xpn"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet_xpn.self_link
  }

  service_account {
    email  = data.google_compute_default_service_account.default_xpn.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_instance" "jumphost_in_vm" {
  depends_on   = [ google_compute_shared_vpc_service_project.service1 ]

  project      = data.google_project.subscr_subscr_vm.name
  zone         = var.zone
  name         = "jumphost-vm"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_subnet_xpn.self_link
  }

  service_account {
    email  = data.google_compute_default_service_account.default_vm.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true
}

resource "google_compute_firewall" "allow-google-lb-hc" {
  name          = "allow-google-lb-hc-${var.name_suffix}"
  project      = data.google_project.subscr_subscr_xpn.name
  network       = google_compute_network.vpc_network_xpn.id

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
  project      = data.google_project.subscr_subscr_xpn.name
  network       = google_compute_network.vpc_network_xpn.id

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
  project      = data.google_project.subscr_subscr_xpn.name
  network       = google_compute_network.vpc_network_xpn.id

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

resource "google_dns_managed_zone" "pga" {
  for_each      = var.pga_domains

  project      = data.google_project.subscr_subscr_xpn.name
  name          = "${each.key}-pga-${var.name_suffix}"
  dns_name      = each.value
  force_destroy = false
  visibility    = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network_xpn.id
    }
  }
}

resource "google_dns_record_set" "pga_cname" {
  for_each = var.pga_domains
  
  project      = data.google_project.subscr_subscr_xpn.name
  name         = "*.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["restricted.${each.value}"]
}

resource "google_dns_record_set" "pga_a" {
  for_each = var.pga_domains
  
  project      = data.google_project.subscr_subscr_xpn.name
  name         = "restricted.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}

resource "google_dns_record_set" "pga_dom_a" {
  for_each = var.pga_domains
  
  project      = data.google_project.subscr_subscr_xpn.name
  name         = "${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}
