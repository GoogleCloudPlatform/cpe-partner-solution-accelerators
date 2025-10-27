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

resource "google_service_account" "keycloak_sa" {
  account_id   = "keycloak-${random_string.suffix.result}"
  display_name = "Service Account for Keycloak for accessing CloudSQL"
}

resource "google_project_iam_member" "keycloak_sa_cloudsql_client" {
  project = data.google_project.project.project_id
  role = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

resource "google_project_iam_member" "keycloak_sa_cloudsql_viewer" {
  project = data.google_project.project.project_id
  role = "roles/cloudsql.viewer"
  member = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

resource "google_project_iam_member" "keycloak_sa_cloudsql_user" {
  project = data.google_project.project.project_id
  role = "roles/cloudsql.instanceUser"
  member = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

resource "google_service_account_iam_member" "keycloak_sa_wi" {
  service_account_id = google_service_account.keycloak_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[keycloak/keycloak]"
}

resource "google_service_account_iam_member" "jumphost_sa_keycloak_user" {
  service_account_id = google_service_account.keycloak_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.jumphost_sa.email}"
}

resource "google_service_account_iam_member" "jumphost_sa_keycloak_token_creator" {
  service_account_id = google_service_account.keycloak_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.jumphost_sa.email}"
}

resource "google_service_account_iam_member" "keycloak_sa_self_user" {
  service_account_id = google_service_account.keycloak_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.keycloak_sa.email}"
}

resource "google_service_account_iam_member" "keycloak_sa_self_token_creator" {
  service_account_id = google_service_account.keycloak_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.keycloak_sa.email}"
}
