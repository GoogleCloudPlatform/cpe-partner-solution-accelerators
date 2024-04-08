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

resource "google_bigquery_analytics_hub_data_exchange" "exchange" {
  project = data.google_project.ah_exchg.project_id
  location         = var.location

  data_exchange_id = "ahdemo_${var.name_suffix}_priv_exchg_ahonly"
  display_name     = "ahdemo-${var.name_suffix} - private - dedicated AH project"
  description      = "ahdemo-${var.name_suffix} - private - dedicated AH project"
}

resource "google_bigquery_analytics_hub_listing" "listing" {
  location         = var.location
  project          = data.google_project.ah_exchg.project_id
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.exchange.data_exchange_id

  listing_id       = "ahdemo_${var.name_suffix}_priv_listing_ahonly"
  display_name     = "ahdemo-${var.name_suffix} - private - dedicated AH project"
  description      = "ahdemo-${var.name_suffix} - private - dedicated AH project"

  request_access   = var.ah_listing_request_access_email_or_url

  bigquery_dataset {
    dataset = google_bigquery_dataset.shared_dataset.id
  }
}

resource "google_bigquery_analytics_hub_data_exchange_iam_policy" "policy" {
  project = google_bigquery_analytics_hub_data_exchange.exchange.project
  location = google_bigquery_analytics_hub_data_exchange.exchange.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.exchange.data_exchange_id
  policy_data = data.google_iam_policy.subscribers.policy_data
}
