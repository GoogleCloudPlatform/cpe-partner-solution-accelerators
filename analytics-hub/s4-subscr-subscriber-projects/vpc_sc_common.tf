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

resource "google_access_context_manager_access_policy" "access_policy" {
    parent = "organizations/${var.subscr_vpc_sc_policy_parent_org_id}"
    title  = var.subscr_vpc_sc_global_access_policy_name
    scopes = []
}

resource "google_access_context_manager_access_level" "access_level_allow_all" {
    description = "Allow all IPv4 and IPv6 ranges"
    name        = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}/accessLevels/ahdemo_${var.name_suffix}_subscr_allow_all"
    parent      = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}"
    title       = "ahdemo_${var.name_suffix}_subscr_allow_all"

    basic {
        combining_function = "AND"

        conditions {
            ip_subnetworks         = [
                "0.0.0.0/0",
                "::/0",
            ]
            members                = []
            negate                 = false
            regions                = []
            required_access_levels = []
        }
    }
}

resource "google_access_context_manager_access_level" "access_level_allow_corp" {
    description = "Allow specific IPv4 and IPv6 ranges for internal users / admins"
    name        = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}/accessLevels/ahdemo_${var.name_suffix}_subscr_allow_corp"
    parent      = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}"
    title       = "ahdemo_${var.name_suffix}_subscr_allow_corp"

    basic {
        combining_function = "AND"

        conditions {
            ip_subnetworks         = var.subscr_vpc_sc_access_level_corp_ip_subnetworks
            members                = []
            negate                 = false
            regions                = []
            required_access_levels = []
        }
    }
}
