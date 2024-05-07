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

resource "google_project_iam_audit_config" "analyticshub-service" {
  for_each = toset( [
    data.google_project.publ_ah_exchg.project_id,
    data.google_project.publ_bq_and_ah.project_id,
    data.google_project.publ_nonvpcsc_ah_exchg.project_id,
    data.google_project.publ_bq_shared_ds.project_id,
    data.google_project.publ_bq_src_ds.project_id,
    ] )

  project = each.value
  service = "analyticshub.googleapis.com"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}

resource "google_project_iam_audit_config" "bigquery-service" {
  for_each = toset( [
    data.google_project.publ_ah_exchg.project_id,
    data.google_project.publ_bq_and_ah.project_id,
    data.google_project.publ_nonvpcsc_ah_exchg.project_id,
    data.google_project.publ_bq_shared_ds.project_id,
    data.google_project.publ_bq_src_ds.project_id,
    ] )

  project = each.value
  service = "bigquery.googleapis.com"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}
