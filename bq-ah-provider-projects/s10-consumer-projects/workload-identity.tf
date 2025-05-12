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
  provider_managed_projects_aws_wf_list = distinct(flatten([
    for user_name, user in var.provider_managed_projects : [
      for aws_federation in toset( user.aws_federations ) : {
        user_name   = user_name
        account_id  = aws_federation.account_id
        role        = aws_federation.role
        wlif_pool_provider_name_suffix = aws_federation.wlif_pool_provider_name_suffix
        project_id     = google_project.cx_projects[user_name].project_id
        project_number     = google_project.cx_projects[user_name].number
      }
    ]
  ]))
}

resource "google_iam_workload_identity_pool" "cx_aws_pool" {
  for_each         = var.provider_managed_projects

  project                   = "${var.prov_project_id_prefix}-cx-${each.key}"
  workload_identity_pool_id = "cxpool-${each.key}"
  display_name              = "cxpool-${each.key}"
  description               = "cxpool-${each.key}"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "cx_aws_pool_provider" {
  for_each         =  {
    for aws_wf in local.provider_managed_projects_aws_wf_list : "${aws_wf.user_name}" => aws_wf
  }

  project = each.value.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.cx_aws_pool[each.key].workload_identity_pool_id
  workload_identity_pool_provider_id = "cxpool-${each.value.user_name}-${each.value.wlif_pool_provider_name_suffix}"
  display_name = "cxpool-${each.value.user_name}-${each.value.wlif_pool_provider_name_suffix}"

  attribute_mapping                  = {
   "attribute.aws_ec2_instance" = "assertion.arn.extract('assumed-role/{role_and_session}').extract('/{session}')"
   "attribute.aws_role"         = "assertion.arn.extract('assumed-role/{role}/')"
   "google.subject"             = "assertion.arn"
  }

  aws {
    account_id = each.value.account_id
  }
}
