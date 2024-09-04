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

terraform {
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
      version = "5.28.0"
    }
    google = {
      source = "hashicorp/google"
      version = "6.1.0"
    }
  }
}

provider "google-beta" {
  project     = var.publ_project_id_seed
  region      = var.region
  zone        = var.zone
  user_project_override = true
  billing_project = var.publ_project_id_seed
}

provider "google" {
  project     = var.publ_project_id_seed
  region      = var.region
  zone        = var.zone
  user_project_override = true
  billing_project = var.publ_project_id_seed
}

# Example: impesonation configuration
# Preferred: setting through environment variables
#   GOOGLE_BACKEND_IMPERSONATE_SERVICE_ACCOUNT
#   GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
#
#provider "google" {
#  alias   = "tokengen"
#}
#
#data "google_client_config" "default" {
#  provider = google.tokengen
#}
#
#data "google_service_account_access_token" "impersonated_sa" {
#  provider               = google.tokengen
#  target_service_account = var.service_account
#  scopes                 = ["userinfo-email", "cloud-platform"]
#  lifetime               = "3600s"
#}
#
#provider "google" {
#  access_token = data.google_service_account_access_token.impersonated_sa.access_token
#
#  project     = var.project_id_seed
#  region      = var.region
#  zone        = var.zone
#  user_project_override = true
#  billing_project = var.project_id_seed
#}
