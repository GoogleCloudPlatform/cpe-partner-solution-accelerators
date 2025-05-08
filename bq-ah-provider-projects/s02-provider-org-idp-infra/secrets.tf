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

resource "google_secret_manager_secret" "keycloak_admin_password" {
  project   = data.google_project.project.project_id
  secret_id = "keycloak-admin-password-${random_string.suffix.result}"

  replication {
    auto {}
  }

  labels = {
    "environment" = "production",
    "app"         = "keycloak"
  }
}

resource "google_secret_manager_secret_version" "keycloak_admin_password_version" {
  secret      = google_secret_manager_secret.keycloak_admin_password.id
  secret_data = random_password.keycloak_admin_pw.result
}

# Grant the GKE Keycloak workload service account access to the secret
resource "google_secret_manager_secret_iam_member" "keycloak_admin_password_accessor" {
  depends_on = [google_secret_manager_secret_version.keycloak_admin_password_version]

  project   = data.google_project.project.project_id
  secret_id = google_secret_manager_secret.keycloak_admin_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.keycloak_sa.email}"
}
