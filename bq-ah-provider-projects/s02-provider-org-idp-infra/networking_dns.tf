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

resource "google_dns_managed_zone" "managed-zone" {
  name          = "${var.dns_zone_name}-${random_string.suffix.result}"
  dns_name      = var.dns_domain_name
  force_destroy = false
  visibility    = "public"
}

resource "google_dns_record_set" "keycloak-address" {
  name = "keycloak.${var.dns_domain_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.managed-zone.name

  rrdatas = [google_compute_global_address.gateway.address]
}

resource "google_certificate_manager_certificate" "managed-zone-wildcard" {
  name        = "managed-zone-wildcard-cert"
  description = "*.${local.dns_name_trimmed} cert"
  scope       = "DEFAULT"
  labels = {
    env = "test"
  }
  managed {
    domains = [
      google_certificate_manager_dns_authorization.managed-zone-wildcard.domain,
      "*.${google_certificate_manager_dns_authorization.managed-zone-wildcard.domain}",
      ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.managed-zone-wildcard.id,
      ]
  }
}

resource "google_certificate_manager_dns_authorization" "managed-zone-wildcard" {
  name        = "managed-zone-wildcard-dns-auth"
  description = "*.${local.dns_name_trimmed} dns auth"
  domain      = local.dns_name_trimmed
}

resource "google_dns_record_set" "acme-challenge" {
  name = google_certificate_manager_dns_authorization.managed-zone-wildcard.dns_resource_record[0].name
  type = google_certificate_manager_dns_authorization.managed-zone-wildcard.dns_resource_record[0].type
  ttl  = 300

  managed_zone = google_dns_managed_zone.managed-zone.name

  rrdatas = [google_certificate_manager_dns_authorization.managed-zone-wildcard.dns_resource_record[0].data]
}

resource "google_certificate_manager_certificate_map" "managed-zone-crt-map" {
  name        = "managed-zone-crt-map"
  description = "managed-zone certificate map"
}

resource "google_certificate_manager_certificate_map_entry" "managed-zone-wildcard-entry" {
  name        = "managed-zone-wildcard-entry"
  description = "managed-zone-wildcardcertificate map entry"
  map = google_certificate_manager_certificate_map.managed-zone-crt-map.name 
  certificates = [google_certificate_manager_certificate.managed-zone-wildcard.id]
  matcher = "PRIMARY"
}

locals {
  dns_name_trimmed = trimsuffix(google_dns_managed_zone.managed-zone.dns_name, ".")
}
