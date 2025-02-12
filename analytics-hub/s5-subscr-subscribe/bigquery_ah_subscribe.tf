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

provider "google" { 
  alias = "impersonation" 
  scopes = [ 
     "https://www.googleapis.com/auth/cloud-platform", 
     "https://www.googleapis.com/auth/userinfo.email", 
   ] 
}

data "google_service_account_access_token" "subscriber-sa" {
  provider               	= google.impersonation
  target_service_account 	= var.subscr_subscriber_sa_email
  scopes                 	= ["userinfo-email", "cloud-platform"]
}

provider "google" {
  alias = "subscriber-impersonation"
  access_token	= data.google_service_account_access_token.subscriber-sa.access_token
}

resource "google_bigquery_analytics_hub_listing_subscription" "subscription" {
#  provider = google.subscriber-impersonation

  location = var.ah_location
  data_exchange_id = var.ah_exchange_name
  listing_id       = var.ah_listing_name
  project          = var.ah_project_id
  destination_dataset {
    description = "tf_${var.ah_project_number}_${var.ah_listing_name}"
    location = var.ah_location
    dataset_reference {
      dataset_id = "tf_${var.ah_project_number}_${var.ah_listing_name}"
      project_id = var.subscr_project_id_subscr_with_vpcsc
    }
  }
}
