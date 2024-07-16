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

module "access_context_manager_policy" {
  source  = "terraform-google-modules/vpc-service-controls/google"
  version = "~> 5.2.1"

  parent_id   = var.prov_vpc_sc_policy_parent_org_id
  policy_name = var.prov_vpc_sc_global_access_policy_name
}

module "access_level_allow_all" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version = "~> 5.2.1"

  policy         = module.access_context_manager_policy.policy_id
  name           = "xocmek_prov_allow_all"
  ip_subnetworks = [ "0.0.0.0/0", "::/0" ]
  description    = "Allow all IPv4 and IPv6 ranges"
}

module "access_level_allow_corp" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version = "~> 5.2.1"

  policy         = module.access_context_manager_policy.policy_id
  name           = "xocmek_prov_allow_corp"
  ip_subnetworks = var.prov_vpc_sc_access_level_corp_ip_subnetworks
  description    = "Allow specific IPv4 and IPv6 ranges"
}
