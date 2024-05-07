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

resource "google_service_account" "terraform_sa" {
  project      = data.google_project.subscr_seed_project.project_id
  account_id   = var.subscr_terraform_sa_name
  display_name = "Service Account for Terraform"
}

resource "google_service_account_iam_member" "terraform_sa_user" {
  for_each           = toset(var.subscr_terraform_sa_users_iam_members)

  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = each.value
}

resource "google_service_account_iam_member" "terraform_sa_token_creator" {
  for_each           = toset(var.subscr_terraform_sa_users_iam_members)

  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}

resource "google_service_account_iam_member" "terraform_sa_self_user" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_service_account_iam_member" "terraform_sa_self_token_creator" {
  service_account_id = google_service_account.terraform_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.terraform_sa.email}"
}

resource "google_service_account" "subscriber_sa" {
  project      = data.google_project.subscr_seed_project.project_id
  account_id   = var.subscr_subscriber_sa_name
  display_name = "Service Account for Subscriber"
}
