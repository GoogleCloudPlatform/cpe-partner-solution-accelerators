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
   project_role_combination_list = distinct(flatten([
    for project in toset( ["${var.publ_project_id_bq_src_ds}","${var.publ_project_id_bq_shared_ds}","${var.publ_project_id_ah_exchg}","${var.publ_project_id_nonvpcsc_ah_exchg}","${var.publ_project_id_bq_and_ah}"] ) : [
      for role in toset( ["roles/editor", "roles/resourcemanager.projectIamAdmin"] ) : [
        for member in toset( var.publ_project_owners ) : {
          project = project
          role    = role
          member  = member
        }
      ]
    ]
  ]))
}

resource "google_project_iam_member" "project_owner" {
  for_each         = { for entry in local.project_role_combination_list: "${entry.project}.${entry.role}.${entry.member}" => entry }

  project          = each.value.project
  role             = each.value.role
  member           = each.value.member
}