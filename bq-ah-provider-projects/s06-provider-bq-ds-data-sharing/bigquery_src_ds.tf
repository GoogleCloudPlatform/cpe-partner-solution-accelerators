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

resource "google_bigquery_dataset" "src_dataset" {
  project       = data.google_project.project.project_id

  dataset_id    = "provider_${var.name_suffix}_src_ds"
  friendly_name = "provider_${var.name_suffix}_src_ds"
  description   = "provider_${var.name_suffix}_src_ds"
  location      = var.location
}

resource "google_bigquery_table" "src_table" {
  project             = data.google_project.project.project_id

  dataset_id          = google_bigquery_dataset.src_dataset.dataset_id
  table_id            = "beverage_sales_data_table"
  deletion_protection = false
  schema              = file("../datasets/synthetic_beverage_sales_data_schema.json")
}

resource "google_storage_bucket" "provider_bqds_bucket" {
  project       = data.google_project.project.project_id

  name          = "${data.google_project.project.project_id}-bucket"
  location      = var.location
  force_destroy = true
  public_access_prevention = "enforced"
}

resource "google_storage_bucket_object" "src_table_data_csv" {
  name   = "bigquery/synthetic_beverage_sales_data.csv"
  source = "../datasets/synthetic_beverage_sales_data.csv"
  bucket = google_storage_bucket.provider_bqds_bucket.name
}

resource "google_storage_bucket_object" "src_table_data_jsonl" {
  name   = "bigquery/synthetic_beverage_sales_data_schema.jsonl"
  source = "../datasets/synthetic_beverage_sales_data_schema.json"
  bucket = google_storage_bucket.provider_bqds_bucket.name
}

resource "google_service_account" "bqdt_service_account" {
  project       = data.google_project.project.project_id

  account_id                   = "bqdt-service-account-${var.name_suffix}"
  display_name                 = "BQ Data Transfer Service Account"
}

resource "google_project_iam_member" "project_bqdt_service_account" {
  for_each = toset( [ "roles/bigquery.admin" ] )
  project  = data.google_project.project.project_id

  role     = each.value
  member   = "serviceAccount:${google_service_account.bqdt_service_account.email}"
}

resource "google_bigquery_data_transfer_config" "src_table_data_csv_import_config" {
  depends_on = [ google_project_iam_member.project_bqdt_service_account ]

  data_refresh_window_days = 0
  data_source_id           = "google_cloud_storage"
  disabled                 = false
  display_name             = "Load data from CSV file on GCS to ${google_bigquery_table.src_table.table_id}"
  location               = var.location
  destination_dataset_id = google_bigquery_dataset.src_dataset.dataset_id
  
  params = {
    data_path_template              = "gs://${google_storage_bucket.provider_bqds_bucket.name}/${google_storage_bucket_object.src_table_data_csv.name}"
    encoding                        = "UTF8"
    field_delimiter                 = ","
    file_format                     = "CSV"
    max_bad_records                 = 1
    skip_leading_rows               = 1
    write_disposition               = "APPEND"
    destination_table_name_template = google_bigquery_table.src_table.table_id
  }

  schedule_options {
    disable_auto_scheduling = true
  }
}
