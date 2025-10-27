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

resource "google_data_catalog_taxonomy" "policy_tags_bq_ah" {
  region = var.location
  display_name =  "policy_tags_bq_ah_${var.name_suffix}"
  description = "A collection of policy tags"
  activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
  project = data.google_project.publ_bq_and_ah.project_id
}

resource "google_data_catalog_policy_tag" "parent_policy_bq_ah" {
  taxonomy = google_data_catalog_taxonomy.policy_tags_bq_ah.id
  display_name = "restricted_bq_ah_${var.name_suffix}"
  description = "A policy tag category used for restricted security access"
}

resource "google_data_catalog_policy_tag" "child_policy_errorcode_bq_ah" {
  taxonomy = google_data_catalog_taxonomy.policy_tags_bq_ah.id
  display_name = "errorcode_bq_ah_${var.name_suffix}"
  description = "Error code"
  parent_policy_tag = google_data_catalog_policy_tag.parent_policy_bq_ah.id
}

data "google_iam_policy" "child_policy_errorcode_bq_ah_iam_policy_data" {
  binding {
    role = "roles/datacatalog.categoryFineGrainedReader"
    members = var.publ_vpc_sc_ah_subscriber_identities
  }
}

resource "google_data_catalog_policy_tag_iam_policy" "child_policy_errorcode_bq_ah_iam_policy" {
  policy_tag = google_data_catalog_policy_tag.child_policy_errorcode_bq_ah.name
  policy_data = data.google_iam_policy.child_policy_errorcode_bq_ah_iam_policy_data.policy_data
}

resource "google_bigquery_datapolicy_data_policy" "data_policy_bq_ah" {
  project = data.google_project.publ_bq_and_ah.project_id
  location         = var.location
  data_policy_id   = "policy_errorcode_bq_ah_${var.name_suffix}"
  policy_tag       = google_data_catalog_policy_tag.child_policy_errorcode_bq_ah.name
  data_policy_type = "DATA_MASKING_POLICY"  
  data_masking_policy {
    predefined_expression = "ALWAYS_NULL"
  }
}

data "google_iam_policy" "data_policy_bq_ah_iam_policy_data" {
  binding {
#    role = "roles/datacatalog.categoryFineGrainedReader"
    role = "roles/bigquerydatapolicy.maskedReader"
    members = var.publ_vpc_sc_ah_subscriber_identities
  }
}

resource "google_bigquery_datapolicy_data_policy_iam_policy" "data_policy_bq_ah_iam_policy" {
  project = data.google_project.publ_bq_and_ah.project_id
  location = var.location
  data_policy_id = google_bigquery_datapolicy_data_policy.data_policy_bq_ah.data_policy_id
  policy_data = data.google_iam_policy.data_policy_bq_ah_iam_policy_data.policy_data
}

resource "google_project_iam_member" "bqah_kms_service_account_access" {
  depends_on = [ null_resource.bq_encryption_service_account_bqah ]

  project = data.google_project.publ_bq_and_ah.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:bq-${data.google_project.publ_bq_and_ah.number}@bigquery-encryption.iam.gserviceaccount.com"
}

resource "null_resource" "bq_encryption_service_account_bqah" {
  provisioner "local-exec" {
    command = "bq show --encryption_service_account --project_id=${data.google_project.publ_bq_and_ah.project_id} && sleep 10"
  }
}

resource "google_bigquery_dataset" "bqah_shared_dataset" {
  depends_on = [ null_resource.bq_encryption_service_account_bqah ]

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
  schema              = var.publ_enable_policy_tags ? templatefile("./bigquery/schema.json.tpl", {policy_tag_name = google_data_catalog_policy_tag.child_policy_errorcode_bq_ah.name}) : file("./bigquery/schema.json")
}

resource "null_resource" "bqah_shared_view_dcr" {
  depends_on = [ google_bigquery_table.bqah_shared_table ]
  triggers = {
   always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "bq query --project_id ${google_bigquery_dataset.bqah_shared_dataset.project} --nouse_legacy_sql 'CREATE OR REPLACE VIEW `${google_bigquery_dataset.bqah_shared_dataset.project}.${google_bigquery_dataset.bqah_shared_dataset.dataset_id}.ahdemo_${var.name_suffix}_bqah_shared_view_dcr` OPTIONS (privacy_policy= \"{\\\"aggregation_threshold_policy\\\": {\\\"threshold\\\" : 1, \\\"privacy_unit_columns\\\": \\\"endpoint\\\"}}\") AS ( select * from `${google_bigquery_dataset.bqah_shared_dataset.project}`.${google_bigquery_dataset.bqah_shared_dataset.dataset_id}.${google_bigquery_table.bqah_shared_table.table_id} )';"
  }
}

# TODO: currently there is no way to provide the OPTIONS statement for creating the view => FR
# resource "google_bigquery_table" "bqah_shared_view_dcr" {
#  depends_on = [ google_bigquery_table.bqah_shared_table ]
#
#  dataset_id          = google_bigquery_dataset.bqah_shared_dataset.dataset_id
#  table_id            = "ahdemo_${var.name_suffix}_bqah_shared_view_dcr"
#  deletion_protection = false
#  project             = data.google_project.publ_bq_and_ah.project_id
#  schema              = file("./bigquery/schema_src.json")
#  view {
#    query = "select * from `${google_bigquery_dataset.bqah_shared_dataset.project}`.${google_bigquery_dataset.bqah_shared_dataset.dataset_id}.${google_bigquery_table.bqah_shared_table.table_id};"
#    use_legacy_sql = false
#  } 
#}

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
