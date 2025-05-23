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

resource "google_bigquery_analytics_hub_listing_subscription" "subscription" {
  for_each         = var.provider_managed_projects

  location         = var.location
  data_exchange_id = local.bqds_exchange_id
  listing_id       = "cx_${var.name_suffix}_listing_${each.key}"
  project          = var.prov_project_id_bqds

  destination_dataset {
    description = "cx_${var.name_suffix}_linked_ds_${each.key}"
    location = var.location
    dataset_reference {
      dataset_id = "cx_${var.name_suffix}_linked_ds_${each.key}"
      project_id = module.project-services-cx[each.key].project_id
    }
  }
}
