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

# Folder for all related projects
resource "google_folder" "prov-root" {
  display_name = "${var.prov_project_id_prefix}-root"
  parent       = "organizations/${var.prov_org_id}"
}

# Folder for provider core projects
resource "google_folder" "prov-core" {
  display_name = "${var.prov_project_id_prefix}-core"
  parent       = google_folder.prov-root.id
}

# Folder for provider data projects
resource "google_folder" "prov-data" {
  display_name = "${var.prov_project_id_prefix}-data"
  parent       = google_folder.prov-root.id
}

# Folder for provider managed (cx) projects
resource "google_folder" "prov-cx" {
  display_name = "${var.prov_project_id_prefix}-cx"
  parent       = google_folder.prov-root.id
}

resource "google_folder_iam_member" "prov-root-folder-iam" {
  for_each = toset( concat(var.prov_project_owners, [ "user:${var.gcloud_user}" ] ) )

  folder  = google_folder.prov-root.id
  role    = "roles/owner"
  member  = each.value
}
