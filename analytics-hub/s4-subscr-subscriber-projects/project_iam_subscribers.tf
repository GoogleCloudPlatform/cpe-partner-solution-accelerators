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

locals {
  ah_subscribers_iam_members = toset(concat(
    var.subscr_subscriber_projects_ah_subscribers_iam_members,
    var.subscr_subscriber_projects_ah_subscription_viewer_iam_members,
    ["serviceAccount:${data.google_service_account.subscriber_sa.email}"]
  ))
}

resource "google_project_iam_member" "project_editor_subscr_with_vpcsc" {
  for_each = local.ah_subscribers_iam_members

  project = data.google_project.subscr_subscr_with_vpcsc.project_id
  role    = "roles/editor"
  member  = each.value
}
resource "google_project_iam_member" "project_editor_subscr_without_vpcsc" {
  for_each = local.ah_subscribers_iam_members

  project = data.google_project.subscr_subscr_without_vpcsc.project_id
  role    = "roles/editor"
  member  = each.value
}
resource "google_project_iam_member" "bqadmin_project_subscr_with_vpcsc" {
  for_each = local.ah_subscribers_iam_members

  project = data.google_project.subscr_subscr_with_vpcsc.project_id
  role    = "roles/bigquery.admin"
  member  = each.value
}
resource "google_project_iam_member" "bqadmin_project_subscr_without_vpcsc" {
  for_each = local.ah_subscribers_iam_members

  project = data.google_project.subscr_subscr_without_vpcsc.project_id
  role    = "roles/bigquery.admin"
  member  = each.value
}
resource "google_project_iam_member" "subscriber_project_subscr_with_vpcsc" {
  for_each = local.ah_subscribers_iam_members

  project = data.google_project.subscr_subscr_with_vpcsc.project_id
  role    = "roles/analyticshub.subscriber"
  member  = each.value
}
resource "google_project_iam_member" "subscriber_project_subscr_without_vpcsc" {
  for_each = local.ah_subscribers_iam_members

  project = data.google_project.subscr_subscr_without_vpcsc.project_id
  role    = "roles/analyticshub.subscriber"
  member  = each.value
}
