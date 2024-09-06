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

module "regular_service_perimeter_subscr_with_vpcsc" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 5.2.1"

  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "xocmek_${var.name_suffix}_provider"
  description    = "xocmek_${var.name_suffix}_provider"

  restricted_services = var.vpc_sc_restricted_services

  access_levels = []

  resources = [ data.google_project.prov_seed_project.number ]

  ingress_policies = [
    # Allow off-perimeter internal users (Cloud Console users) in var.prov_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
    # required for the (internal) admins
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_corp.name ] # Allow access from corporate network IP ranges
          resources = []
        },
        "identities" = var.prov_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.prov_seed_project.number}",
        ]
        "operations" = {
          "cloudkms.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
        }
      }
    },
  ]

  egress_policies = [
    # Allow egress to var.cust_project_number_seed from the compute service agent
    # required for creating the view from shared_ds/bq_and_ah to src_ds
    {
      "from" = {
        "identities" = [
          "serviceAccount:service-${data.google_project.prov_seed_project.number}@compute-system.iam.gserviceaccount.com"
          ]
      }
      "to" = {
        "resources" = [
          "projects/${var.cust_project_number_seed}",
        ]
        "operations" = {
          "cloudkms.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    },
  ]
}
