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

resource "google_bigquery_dataset" "src_dataset_authz" {
  dataset_id    = "ahdemo_${var.name_suffix}_src_ds_authz"
  friendly_name = "ahdemo_${var.name_suffix}_src_ds_authz"
  description   = "ahdemo_${var.name_suffix}_src_ds_authz"
  location      = var.location
  project       = data.google_project.publ_bq_src_ds.project_id

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }

  access {
    dataset {
      dataset {
        project_id = google_bigquery_dataset.shared_dataset.project
        dataset_id = google_bigquery_dataset.shared_dataset.dataset_id
      }
      target_types = ["VIEWS"]
    }
  }
  access {
    dataset {
      dataset {
        project_id = google_bigquery_dataset.bqah_shared_dataset.project
        dataset_id = google_bigquery_dataset.bqah_shared_dataset.dataset_id
      }
      target_types = ["VIEWS"]
    }
  }
}

resource "google_bigquery_table" "src_table_authz" {
  dataset_id          = google_bigquery_dataset.src_dataset_authz.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_src_table_authz"
  deletion_protection = false
  project             = data.google_project.publ_bq_src_ds.project_id
  schema              = var.publ_enable_policy_tags ? templatefile("./bigquery/schema_src.json.tpl", {policy_tag_name = google_data_catalog_policy_tag.child_policy_errorcode_src_ds.name}) : file("./bigquery/schema_src.json")
}

resource "google_bigquery_table" "src_fed_view_authz" {
  dataset_id          = google_bigquery_dataset.src_dataset_authz.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_src_fed_view_authz"
  deletion_protection = false
  project             = data.google_project.publ_bq_src_ds.project_id
  schema              = file("./bigquery/schema_src.json")
  view {
    query = "select * from `${google_bigquery_dataset.fed_views_dataset.project}`.${google_bigquery_dataset.fed_views_dataset.dataset_id}.${google_bigquery_table.fed_shared_authz_view.table_id};"
    use_legacy_sql = false
  }
}
