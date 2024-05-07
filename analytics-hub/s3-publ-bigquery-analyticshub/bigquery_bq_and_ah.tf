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

resource "google_bigquery_dataset" "bqah_shared_dataset" {
  dataset_id    = "ahdemo_${var.name_suffix}_bqah_shared_ds"
  friendly_name = "ahdemo_${var.name_suffix}_bqah_shared_ds"
  description   = "ahdemo_${var.name_suffix}_bqah_shared_ds"
  location      = var.location
  project       = data.google_project.publ_bq_and_ah.project_id
}

resource "google_bigquery_table" "bqah_shared_table" {
  dataset_id          = google_bigquery_dataset.bqah_shared_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_bqah_shared_table"
  deletion_protection = false
  project             = data.google_project.publ_bq_and_ah.project_id
  schema              = file("./bigquery/schema.json")
}

resource "google_bigquery_job" "bqah_shared_table_load" {
  job_id  = "ahdemo_${var.name_suffix}_bqah_shared_table_job_load"
  project = data.google_project.publ_bq_and_ah.project_id

  load {
    source_uris = [
      "gs://${var.publ_tf_state_bucket}/${google_storage_bucket_object.shared_table_data_jsonl.name}",
    ]

    destination_table {
      project_id = data.google_project.publ_bq_and_ah.project_id
      dataset_id = google_bigquery_dataset.bqah_shared_dataset.dataset_id
      table_id   = google_bigquery_table.bqah_shared_table.table_id
    }

    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
  }
}

resource "google_bigquery_table" "bqah_shared_view" {
  depends_on = [ google_bigquery_table.src_table ]

  dataset_id          = google_bigquery_dataset.bqah_shared_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_bqah_shared_view_from_src_ds"
  deletion_protection = false
  project             = data.google_project.publ_bq_and_ah.project_id
  schema              = file("./bigquery/schema_src.json")
  view {
    query = "select * from `${google_bigquery_dataset.src_dataset.project}`.${google_bigquery_dataset.src_dataset.dataset_id}.${google_bigquery_table.src_table.table_id};"
    use_legacy_sql = false
  } 
}

resource "google_bigquery_table" "bqah_shared_authz_view" {
  depends_on = [ google_bigquery_table.src_table_authz ]

  dataset_id          = google_bigquery_dataset.bqah_shared_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_bqah_shared_authz_view_from_src_ds"
  deletion_protection = false
  project             = data.google_project.publ_bq_and_ah.project_id
  schema              = file("./bigquery/schema_src.json")
  view {
    query = "select * from `${google_bigquery_dataset.src_dataset.project}`.${google_bigquery_dataset.src_dataset_authz.dataset_id}.${google_bigquery_table.src_table_authz.table_id};"
    use_legacy_sql = false
  } 
}
