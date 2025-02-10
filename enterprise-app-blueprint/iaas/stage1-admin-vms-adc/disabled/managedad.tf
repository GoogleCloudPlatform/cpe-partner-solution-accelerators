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

resource "google_active_directory_domain" "mgad" {
  domain_name       = trimsuffix(var.managed_ad_dns_domain, ".")
  locations         = [ var.locations["fra"].region ]
  reserved_ip_range = var.networks["main"].managed_ad_cidr
  deletion_protection = false
  authorized_networks = [
    google_compute_network.vpc_network["main"].id,
    google_compute_network.vpc_network["dmz"].id
  ]

  # Terraform wanted to recreate the Managed AD resource after successful import, based on the domain_name field missing.
  lifecycle {
    ignore_changes = [domain_name]
  }
}
