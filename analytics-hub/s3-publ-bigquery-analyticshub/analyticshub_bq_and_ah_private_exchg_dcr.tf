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

resource "google_bigquery_analytics_hub_data_exchange" "bqah_exchange_dcr" {
  depends_on       = [ null_resource.bqah_shared_view_dcr ]

  project          = data.google_project.publ_bq_and_ah.project_id
  location         = var.location
  
  data_exchange_id = "ahdemo_${var.name_suffix}_priv_bqah_dcr"
  display_name     = "ahdemo_${var.name_suffix}_priv_bqah_dcr"
  description      = "ahdemo-${var.name_suffix}_priv_bqah_dcr"

  sharing_environment_config  {
    dcr_exchange_config {}
  }
}

resource "google_bigquery_analytics_hub_listing" "bqah_listing_dcr" {
  depends_on       = [ null_resource.bqah_shared_view_dcr ]

  location         = var.location
  project          = data.google_project.publ_bq_and_ah.project_id
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.bqah_exchange_dcr.data_exchange_id

  listing_id       = "ahdemo_${var.name_suffix}_priv_bqah_dcr"
  display_name     = "ahdemo-${var.name_suffix}_priv_bqah_dcr"
  description      = "ahdemo-${var.name_suffix}_priv_bqah_dcr"

  request_access   = var.publ_ah_listing_request_access_email_or_url

  bigquery_dataset {
    dataset = google_bigquery_dataset.bqah_shared_dataset.id
    selected_resources {
      table = "projects/${google_bigquery_dataset.bqah_shared_dataset.project}/datasets/${google_bigquery_dataset.bqah_shared_dataset.dataset_id}/tables/ahdemo_${var.name_suffix}_bqah_shared_view_dcr"
    }
  }

  restricted_export_config {
    enabled                   = true
  }
}

resource "google_bigquery_analytics_hub_data_exchange_iam_policy" "bqah_policy_dcr" {
  project = google_bigquery_analytics_hub_data_exchange.bqah_exchange_dcr.project
  location = google_bigquery_analytics_hub_data_exchange.bqah_exchange_dcr.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.bqah_exchange_dcr.data_exchange_id
  policy_data = data.google_iam_policy.private_subscribers.policy_data
}
