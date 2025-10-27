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

resource "google_bigquery_dataset" "shared_cx_dataset" {
  project       = data.google_project.project.project_id
  for_each      = var.provider_managed_projects

  dataset_id    = "provider_${var.name_suffix}_cx_${each.key}"
  friendly_name = "provider_${var.name_suffix}_cx_${each.key}"
  description   = "provider_${var.name_suffix}_cx_${each.key}"
  location      = var.location
}

resource "google_bigquery_table" "shared_cx_view" {
  project             = data.google_project.project.project_id
  for_each            = var.provider_managed_projects

  dataset_id          = google_bigquery_dataset.shared_cx_dataset[each.key].dataset_id
  table_id            = "beverage_sales_data_view"
  deletion_protection = false
  schema              = file("../datasets/synthetic_beverage_sales_data_schema.json")
  view {
    query = "select * from `${google_bigquery_dataset.src_dataset.project}`.${google_bigquery_dataset.src_dataset.dataset_id}.${google_bigquery_table.src_table.table_id} where Customer_ID = \"${each.value.customer_id}\";"
    use_legacy_sql = false
  }
}

resource "google_bigquery_dataset_access" "shared_cx_ds_access" {
  project             = data.google_project.project.project_id
  for_each            = var.provider_managed_projects

  dataset_id    = google_bigquery_dataset.src_dataset.dataset_id
  view {
    project_id = google_bigquery_dataset.src_dataset.project
    dataset_id = google_bigquery_dataset.shared_cx_dataset[each.key].dataset_id
    table_id   = google_bigquery_table.shared_cx_view[each.key].table_id
  }
}
