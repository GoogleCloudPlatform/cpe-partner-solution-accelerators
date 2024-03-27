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
  dataset_id    = "ahdemo_${var.name_suffix}_src_ds"
  friendly_name = "ahdemo_${var.name_suffix}_src_ds"
  description   = "ahdemo_${var.name_suffix}_src_ds"
  location      = var.location
  project       = data.google_project.bq_src_ds.project_id
}

resource "google_bigquery_table" "src_table" {
  dataset_id          = google_bigquery_dataset.src_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_src_table"
  deletion_protection = false
  project             = data.google_project.bq_src_ds.project_id
  schema              = file("./bigquery/schema_src.json")
}

resource "google_bigquery_job" "src_table_load" {
  job_id  = "ahdemo_${var.name_suffix}_src_table_job_load"
  project = data.google_project.bq_src_ds.project_id

  load {
    source_uris = [
      "gs://${var.tf_state_bucket}/${google_storage_bucket_object.src_table_data_jsonl.name}",
    ]

    destination_table {
      project_id = data.google_project.bq_src_ds.project_id
      dataset_id = google_bigquery_dataset.src_dataset.dataset_id
      table_id   = google_bigquery_table.src_table.table_id
    }

    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
  }
}

#data "google_iam_policy" "src_ds_reader" {
#  binding {
#    role = "roles/bigquery.dataViewer"
#    members = var.ah_subscribers_iam_members
#  }
#}
#
#resource "google_bigquery_table_iam_policy" "policy" {
#  project = google_bigquery_dataset.src_dataset.project
#  dataset_id = google_bigquery_dataset.src_dataset.dataset_id
#  table_id = google_bigquery_table.src_table.table_id
#  policy_data = data.google_iam_policy.src_ds_reader.policy_data
#}
