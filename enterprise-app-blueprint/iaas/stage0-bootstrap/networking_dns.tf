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

resource "google_dns_managed_zone" "pga" {
  for_each = var.pga_domains

  name          = "${each.key}-pga"
  dns_name      = each.value
  force_destroy = false
  visibility    = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network["main"].id
    }
    networks {
      network_url = google_compute_network.vpc_network["dmz"].id
    }
  }
}

resource "google_dns_record_set" "pga_cname" {
  for_each = var.pga_domains
  
  name         = "*.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["private.${each.value}"]
}

resource "google_dns_record_set" "pga_a" {
  for_each = var.pga_domains
  
  name         = "private.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

resource "google_dns_record_set" "pga_dom_a" {
  for_each = var.pga_domains
  
  name         = "${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

resource "google_dns_managed_zone" "dns" {
  name          = "${var.dns_zone_name}"
  dns_name      = var.dns_custom_domain
  force_destroy = false
  visibility    = "public"
}
