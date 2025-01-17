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

data "google_service_account" "subscriber_sa" {
  project      = data.google_project.subscr_seed_project.project_id
  account_id   = var.subscr_subscriber_sa_email
}

resource "google_service_account_iam_member" "subscriber_sa_user" {
  for_each = toset(concat(var.subscr_subscriber_sa_users_iam_members, [ "serviceAccount:${data.google_compute_default_service_account.default_xpn.email}", "serviceAccount:${data.google_compute_default_service_account.default_vm.email}" ]) )

  service_account_id = data.google_service_account.subscriber_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = each.key
}

resource "google_service_account_iam_member" "subscriber_sa_token_creator" {
  for_each = toset(concat(var.subscr_subscriber_sa_users_iam_members, [ "serviceAccount:${data.google_compute_default_service_account.default_xpn.email}", "serviceAccount:${data.google_compute_default_service_account.default_vm.email}" ]) )

  service_account_id = data.google_service_account.subscriber_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.key
}
