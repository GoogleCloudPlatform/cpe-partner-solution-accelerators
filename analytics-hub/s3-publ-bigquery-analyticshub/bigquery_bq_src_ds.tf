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

resource "google_kms_key_ring" "src_ds_key_ring" {
  project  = data.google_project.publ_bq_src_ds.project_id
  location = "us"
  name     = "ahdemo_${var.name_suffix}_bq_src_ds_keyring"
}

resource "google_kms_crypto_key" "src_ds_crypto_key" {
  name     = "ahdemo_${var.name_suffix}_bq_src_ds_key"
  key_ring = google_kms_key_ring.src_ds_key_ring.id
}

resource "google_project_iam_member" "bq_src_ds_kms_service_account_access" {
  project = data.google_project.publ_bq_src_ds.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:bq-${data.google_project.publ_bq_src_ds.number}@bigquery-encryption.iam.gserviceaccount.com"
}

resource "google_bigquery_dataset" "src_dataset" {
  dataset_id    = "ahdemo_${var.name_suffix}_src_ds"
  friendly_name = "ahdemo_${var.name_suffix}_src_ds"
  description   = "ahdemo_${var.name_suffix}_src_ds"
  location      = var.location
  project       = data.google_project.publ_bq_src_ds.project_id
}

resource "google_bigquery_table" "src_table" {
  dataset_id          = google_bigquery_dataset.src_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_src_table"
  deletion_protection = false
  project             = data.google_project.publ_bq_src_ds.project_id
  schema              = file("./bigquery/schema_src.json")
}

#####################################################
# If you want to test access to the source dataset  #
# through non-authorized views, uncomment.          #
#####################################################
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
