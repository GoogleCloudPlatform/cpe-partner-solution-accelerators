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

output "bqds_exchange_data_exchange_id" {
  description = "BigQuery Data Exchange ID"
  value       = google_bigquery_analytics_hub_data_exchange.prov_exchange.data_exchange_id
  sensitive = false
}
output "bqds_exchange_id" {
  description = "BigQuery Data Exchange ID"
  value       = google_bigquery_analytics_hub_data_exchange.prov_exchange.id
  sensitive = false
}
#output "bqds_listings" {
#  description = "BigQuery per-customer listings"
#  value       = google_bigquery_analytics_hub_listing.cx_listing.*.listing_id
#  sensitive = false
#}
