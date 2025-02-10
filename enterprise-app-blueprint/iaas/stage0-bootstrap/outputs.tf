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

output "psa_ip" {
  description = "Private service access (PSA) CIDR range"
  value       = var.psa_ip
}
output "project_id" {
  description = "Project ID"
  value       = data.google_project.project.project_id
}
output "project_number" {
  description = "Project Number"
  value       = data.google_project.project.number
}
output "allowlisted_external_ip_ranges" {
  description = "Allowlisted external range for GKE, SSH, etc"
  value       = var.allowlisted_external_ip_ranges
}
output "allowlisted_external_ip_ranges_v4only" {
  description = "Allowlisted external IPv4 range for GKE, SSH, etc"
  value       = var.allowlisted_external_ip_ranges_v4only
}
output "jumphost_sa_email" {
  description = "Jumphost SA email"
  value       = google_service_account.jumphost_sa.email
}
output "vm_sa_email" {
  description = "GCE VM SA email"
  value       = google_service_account.vm_sa.email
}
output "dns_zone_name" {
  description = "DNS zone name"
  value       = google_dns_managed_zone.dns.name
}
output "dns_zone_nameserver" {
  description = "DNS zone nameserver"
  value       = google_dns_managed_zone.dns.name_servers
}
