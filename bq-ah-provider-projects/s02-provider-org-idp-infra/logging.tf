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

# BigQuery dataset in central logging project

resource "google_bigquery_dataset" "central_logs" {
  dataset_id                 = var.logging_bigquery_dataset
  project                    = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.project_id_logging
  location                   = var.region
  delete_contents_on_destroy = true
}

# Logging sink at folder level 
resource "google_logging_folder_sink" "route_to_central" {
  name        = var.logging_folder_sink
  folder      = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.folder_id_cx
  destination = "bigquery.googleapis.com/projects/${data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.project_id_logging}/datasets/${google_bigquery_dataset.central_logs.dataset_id}"
  bigquery_options {
    use_partitioned_tables = true
  }
  # Optional log filter
  # filter = var.log_filter 
}

# Grant sink writer identity access to the central dataset
resource "google_bigquery_dataset_iam_member" "sink_writer" {
  dataset_id = google_bigquery_dataset.central_logs.dataset_id
  project    = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.project_id_logging
  role       = var.bq_dataset_writer_role
  member     = google_logging_folder_sink.route_to_central.writer_identity
}

# Allow logging service account in each customer project to run BQ jobs
resource "google_project_iam_member" "customer_job_user" {
  project = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.project_id_logging
  role    = var.bq_job_user_role
  member  = google_logging_folder_sink.route_to_central.writer_identity
}
