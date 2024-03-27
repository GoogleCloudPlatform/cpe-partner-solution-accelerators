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

resource "google_bigquery_dataset" "private_dataset" {
  dataset_id    = "ahdemo_${var.name_suffix}_private_ds"
  friendly_name = "ahdemo_${var.name_suffix}_private_ds"
  description   = "ahdemo_${var.name_suffix}s_private_ds"
  location      = var.location
  project       = data.google_project.bq_shared_ds.project_id

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

resource "google_bigquery_table" "private_src_table" {
  dataset_id          = google_bigquery_dataset.private_dataset.dataset_id
  table_id            = "ahdemo_${var.name_suffix}_src_table"
  deletion_protection = false
  project             = data.google_project.bq_shared_ds.project_id
  schema              = file("./bigquery/schema_src.json")
}

resource "google_bigquery_job" "private_src_table_load" {
  job_id  = "ahdemo_${var.name_suffix}_private_src_table_job_load"
  project = data.google_project.bq_shared_ds.project_id

  load {
    source_uris = [
      "gs://${var.tf_state_bucket}/${google_storage_bucket_object.src_table_data_jsonl.name}",
    ]

    destination_table {
      project_id = data.google_project.bq_shared_ds.project_id
      dataset_id = google_bigquery_dataset.private_dataset.dataset_id
      table_id   = google_bigquery_table.private_src_table.table_id
    }

    autodetect    = true
    source_format = "NEWLINE_DELIMITED_JSON"
  }
}
