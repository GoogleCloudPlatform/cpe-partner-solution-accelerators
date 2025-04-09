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
  project_role_combination_list_owners = distinct(flatten([
    for user_name, user in var.provider_managed_projects : [
      for role in toset( ["roles/editor", "roles/resourcemanager.projectIamAdmin"] ) : [
        for member in toset( var.prov_project_owners ) : {
          project = "bqprovpr-0819c0-cx-${user_name}"
          role    = role
          member  = member
        }
      ]
    ]
  ]))
}

locals {
  project_role_combination_list_wfif_users = distinct(flatten([
    for user_name, user in var.provider_managed_projects : [
      for role in toset( ["roles/bigquery.dataViewer", "roles/bigquery.jobUser"] ) : {
        project = "bqprovpr-0819c0-cx-${user_name}"
        role    = role
        member  = "${local.wfif_iam_principal}${local.keycloak_users[user_name]}"
      }
    ]
  ]))

  project_role_combination_list_external_users = distinct(flatten([
    for user_name, user in var.provider_managed_projects : [
      for external_identity in toset(user.external_identities) : [
        for role in toset( ["roles/bigquery.dataViewer", "roles/bigquery.jobUser"] ) : {
          project = "bqprovpr-0819c0-cx-${user_name}"
          role    = role
          member  = "user:${external_identity}"
        }
      ]
    ]
  ]))

}

resource "google_project_iam_member" "project_owner" {
  for_each         = { for entry in local.project_role_combination_list_owners: "${entry.project}.${entry.role}.${entry.member}" => entry }
  depends_on       = [ module.project-services-cx ]

  project          = each.value.project
  role             = each.value.role
  member           = each.value.member
}

resource "google_project_iam_member" "project_user" {
  for_each         = { for entry in local.project_role_combination_list_wfif_users: "${entry.project}.${entry.role}.${entry.member}" => entry }
  depends_on       = [ module.project-services-cx ]

  project          = each.value.project
  role             = each.value.role
  member           = each.value.member
}

resource "google_project_iam_member" "project_external_user" {
  for_each         = { for entry in local.project_role_combination_list_external_users: "${entry.project}.${entry.role}.${entry.member}" => entry }
  depends_on       = [ module.project-services-cx ]

  project          = each.value.project
  role             = each.value.role
  member           = each.value.member
}
