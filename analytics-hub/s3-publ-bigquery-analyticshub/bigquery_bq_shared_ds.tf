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

resource "google_data_catalog_taxonomy" "policy_tags_shared_ds" {
  region = var.location
  display_name =  "policy_tags_shared_ds"
  description = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
  project = data.google_project.publ_bq_shared_ds.project_id
}

resource "google_data_catalog_policy_tag" "parent_policy_shared_ds" {
  taxonomy = google_data_catalog_taxonomy.policy_tags_shared_ds.id
  display_name = "restricted_shared_ds"
  description = "A policy tag category used for restricted security access"
}

resource "google_data_catalog_policy_tag" "child_policy_errorcode_shared_ds" {
  taxonomy = google_data_catalog_taxonomy.policy_tags_shared_ds.id
  display_name = "errorcode_shared_ds"
  description = "Error code"
  parent_policy_tag = google_data_catalog_policy_tag.parent_policy_shared_ds.id
}

data "google_iam_policy" "child_policy_errorcode_shared_ds_iam_policy_data" {
  binding {
    role = "roles/datacatalog.categoryFineGrainedReader"
    members = var.publ_vpc_sc_ah_subscriber_identities
  }
}

resource "google_data_catalog_policy_tag_iam_policy" "child_policy_errorcode_shared_ds_iam_policy" {
  policy_tag = google_data_catalog_policy_tag.child_policy_errorcode_shared_ds.name
  policy_data = data.google_iam_policy.child_policy_errorcode_shared_ds_iam_policy_data.policy_data
}

resource "google_bigquery_datapolicy_data_policy" "data_policy_shared_ds" {
  project = data.google_project.publ_bq_shared_ds.project_id
  location         = var.location
  data_policy_id   = "policy_errorcode_shared_ds"
  policy_tag       = google_data_catalog_policy_tag.child_policy_errorcode_shared_ds.name
  data_policy_type = "DATA_MASKING_POLICY"  
  data_masking_policy {
    predefined_expression = "ALWAYS_NULL"
  }
}

data "google_iam_policy" "data_policy_shared_ds_iam_policy_data" {
  binding {
#    role = "roles/datacatalog.categoryFineGrainedReader"
    role = "roles/bigquerydatapolicy.maskedReader"
    members = var.publ_vpc_sc_ah_subscriber_identities
  }
}

resource "google_bigquery_datapolicy_data_policy_iam_policy" "data_policy_shared_ds_iam_policy" {
  project = data.google_project.publ_bq_shared_ds.project_id
  location = var.location
  data_policy_id = google_bigquery_datapolicy_data_policy.data_policy_shared_ds.data_policy_id
  policy_data = data.google_iam_policy.data_policy_shared_ds_iam_policy_data.policy_data
}

resource "google_kms_key_ring" "shared_ds_key_ring" {
  project  = data.google_project.publ_bq_shared_ds.project_id
  location = var.location
  name     = "ahdemo_${var.name_suffix}_bq_shared_ds_keyring_${var.location}"
}

resource "google_kms_crypto_key" "shared_ds_crypto_key" {
  name     = "ahdemo_${var.name_suffix}_bq_shared_ds_key"
  key_ring = google_kms_key_ring.shared_ds_key_ring.id
}

resource "google_project_iam_member" "service_account_access" {
  project = data.google_project.publ_bq_shared_ds.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:bq-${data.google_project.publ_bq_shared_ds.number}@bigquery-encryption.iam.gserviceaccount.com"
}

resource "null_resource" "bq_encryption_service_account_bq_shared_ds" {
  provisioner "local-exec" {
    command = "bq show --encryption_service_account --project_id=${data.google_project.publ_bq_shared_ds.project_id}"
  }
}

resource "google_bigquery_dataset" "shared_dataset" {
  depends_on    = [ google_project_iam_member.service_account_access, null_resource.bq_encryption_service_account_bq_shared_ds ]

  dataset_id    = "ahdemo_${var.name_suffix}_shared_ds"
  friendly_name = "ahdemo_${var.name_suffix}_shared_ds"
  description   = "ahdemo_${var.name_suffix}_shared_ds"
  location      = var.location
  project       = data.google_project.publ_bq_shared_ds.project_id

  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.shared_ds_crypto_key.id
  }
}

resource "google_bigquery_table" "shared_table" {
  dataset_id          = google_bigquery_dataset.shared_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_shared_table"
  deletion_protection = false
  project             = data.google_project.publ_bq_shared_ds.project_id
  schema              = templatefile("./bigquery/schema.json.tpl", {policy_tag_name = google_data_catalog_policy_tag.child_policy_errorcode_shared_ds.name})

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.shared_ds_crypto_key.id
  }
}

resource "google_bigquery_table" "shared_view" {
  depends_on = [ google_bigquery_table.src_table ]

  dataset_id          = google_bigquery_dataset.shared_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_shared_view_from_src_ds"
  deletion_protection = false
  project             = data.google_project.publ_bq_shared_ds.project_id
  schema              = file("./bigquery/schema_src.json")
  view {
    query = "select * from `${google_bigquery_dataset.src_dataset.project}`.${google_bigquery_dataset.src_dataset.dataset_id}.${google_bigquery_table.src_table.table_id};"
    use_legacy_sql = false
  }
}

resource "google_bigquery_table" "shared_authz_view" {
  depends_on = [ google_bigquery_table.src_table_authz ]

  dataset_id          = google_bigquery_dataset.shared_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_shared_authz_view_from_src_ds"
  deletion_protection = false
  project             = data.google_project.publ_bq_shared_ds.project_id
  schema              = file("./bigquery/schema_src.json")
  view {
    query = "select * from `${google_bigquery_dataset.src_dataset.project}`.${google_bigquery_dataset.src_dataset_authz.dataset_id}.${google_bigquery_table.src_table_authz.table_id};"
    use_legacy_sql = false
  } 
}

resource "google_bigquery_table" "shared_authz_view_private_ds" {
  depends_on = [ google_bigquery_table.private_src_table ]

  dataset_id          = google_bigquery_dataset.shared_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_shared_authz_view_from_private_ds"
  deletion_protection = false
  project             = data.google_project.publ_bq_shared_ds.project_id
  schema              = file("./bigquery/schema_src.json")
  view {
    query = "select * from `${data.google_project.publ_bq_shared_ds.project_id}`.${google_bigquery_dataset.private_dataset.dataset_id}.${google_bigquery_table.private_src_table.table_id};"
    use_legacy_sql = false
  }
}
