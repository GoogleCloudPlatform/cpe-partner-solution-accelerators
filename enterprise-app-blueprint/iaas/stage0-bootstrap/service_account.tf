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

resource "google_service_account" "vm_sa" {
  account_id   = "vm-default"
  display_name = "Service Account for GCE VMs"
}

resource "google_service_account" "vm_sa_adsrv" {
  account_id   = "vm-adsrv"
  display_name = "Service Account for the ADC GCE VM"
}

resource "google_service_account" "jumphost_sa" {
  account_id   = "jumphost-editor"
  display_name = "Service Account for Jumphost"
}

resource "google_project_iam_member" "project_vm_sa_adsrv" {
  count = length(var.vm_sa_roles)

  project = data.google_project.project.project_id
  role    = var.vm_sa_roles[count.index]
  member  = "serviceAccount:${google_service_account.vm_sa_adsrv.email}"
}

resource "google_project_iam_member" "project_vm_sa" {
  count = length(var.vm_sa_roles)

  project = data.google_project.project.project_id
  role    = var.vm_sa_roles[count.index]
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_project_iam_member" "project_jumphost" {
  project = data.google_project.project.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.jumphost_sa.email}"
}

resource "google_service_account_iam_member" "jumphost_sa_self_user" {
  service_account_id = google_service_account.jumphost_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.jumphost_sa.email}"
}

resource "google_service_account_iam_member" "jumphost_sa_self_token_creator" {
  service_account_id = google_service_account.jumphost_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.jumphost_sa.email}"
}
