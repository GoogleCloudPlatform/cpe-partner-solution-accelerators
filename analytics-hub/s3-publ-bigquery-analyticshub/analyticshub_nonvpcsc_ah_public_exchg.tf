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

resource "google_bigquery_analytics_hub_data_exchange" "nonvpcsc_public_exchange" {
  project          = data.google_project.publ_nonvpcsc_ah_exchg.project_id
  location         = var.location
  
  data_exchange_id = "ahdemo_${var.name_suffix}_publ_exchg_ahonly_nonvpcsc"
  display_name     = "ahdemo-${var.name_suffix} - public - non-VPCSC dedicated AH project"
  description      = "ahdemo-${var.name_suffix} - public - non-VPCSC dedicated AH project"
}

resource "google_bigquery_analytics_hub_listing" "nonvpcsc_public_listing" {
  location         = var.location
  project          = data.google_project.publ_nonvpcsc_ah_exchg.project_id
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.nonvpcsc_public_exchange.data_exchange_id

  listing_id       = "ahdemo_${var.name_suffix}_publ_listing_ahonly_nonvpcsc"
  display_name     = "ahdemo-${var.name_suffix} - public - non-VPCSC dedicated AH project"
  description      = "ahdemo-${var.name_suffix} - public - non-VPCSC dedicated AH project"

  request_access   = var.publ_ah_listing_request_access_email_or_url

  bigquery_dataset {
    dataset = google_bigquery_dataset.shared_dataset.id
  }
}

resource "google_bigquery_analytics_hub_data_exchange_iam_policy" "nonvpcsc_ah_public_policy" {
  project = google_bigquery_analytics_hub_data_exchange.nonvpcsc_public_exchange.project
  location = google_bigquery_analytics_hub_data_exchange.nonvpcsc_public_exchange.location
  data_exchange_id = google_bigquery_analytics_hub_data_exchange.nonvpcsc_public_exchange.data_exchange_id
  policy_data = data.google_iam_policy.public_subscribers.policy_data
}
