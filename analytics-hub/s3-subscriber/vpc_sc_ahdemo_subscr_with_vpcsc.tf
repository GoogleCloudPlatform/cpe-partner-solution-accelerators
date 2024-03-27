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
  ingress_policies_subscriber_perimeter = [
    # Allow off-perimeter internal users including subscribers (Cloud Console users) in [var.vpc_sc_access_level_corp_allowed_identities + var.vpc_sc_ah_subscriber_identities] from the corporate network IP ranges
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_corp.name ] # Allow access from corporate network IP ranges
        },
        "identities" = concat(var.vpc_sc_subscriber_access_level_corp_allowed_identities, var.vpc_sc_ah_subscriber_identities)
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.subscr_with_vpcsc.number}",
        ]
        "operations" = {
          "analyticshub.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    },
  ]

  egress_policies_subscriber_perimeter = [
    # Allow egress to ah_exchg,bq_and_ah (Google Service -> Google Service) - required for subscribing to the listing
    {
      "from" = {
        "identities" = var.vpc_sc_ah_subscriber_identities
      }
      "to" = {
        "resources" = [
          "projects/${data.google_project.ah_exchg.number}",
          "projects/${data.google_project.bq_and_ah.number}",
          "projects/${data.google_project.nonvpcsc_ah_exchg.number}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    },
  ]
}

module "regular_service_perimeter_subscr_with_vpcsc" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 5.2.1"

  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "ahdemo_subscr_with_vpcsc_perimeter"
  description    = "ahdemo_subscr_with_vpcsc_perimeter"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.subscr_with_vpcsc.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.subscr_with_vpcsc.number ] : []

  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_subscriber_perimeter
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_subscriber_perimeter : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_subscriber_perimeter
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_subscriber_perimeter : []
}
