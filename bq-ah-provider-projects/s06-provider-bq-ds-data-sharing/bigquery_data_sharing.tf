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

resource "google_bigquery_analytics_hub_data_exchange" "prov_exchange" {
  project          = data.google_project.project.project_id
  location         = var.location

  data_exchange_id = "prov_${var.name_suffix}_cx_exchange"
  display_name     = "prov_${var.name_suffix}_cx_exchange"
  description      = "prov_${var.name_suffix}_cx_exchange"
}

resource "google_bigquery_analytics_hub_listing" "cx_listing" {
  project          = data.google_project.project.project_id
  for_each         = var.provider_managed_projects

  location         = var.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.prov_exchange.data_exchange_id

  listing_id       = "cx_${var.name_suffix}_listing_${each.key}"
  display_name     = "cx_${var.name_suffix}_listing_${each.key}"
  description      = "cx_${var.name_suffix}_listing_${each.key}"

  request_access   = var.prov_admin_user

  bigquery_dataset {
    dataset = google_bigquery_dataset.shared_cx_dataset[each.key].id
  }
}
