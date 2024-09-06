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
    # Allow off-perimeter internal users including subscribers (Cloud Console users) in var.subscr_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
    # required for the (internal) admins / subscribers to manage BQ / AH
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_corp.name ] # Allow access from corporate network IP ranges
          resources = []
        },
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.subscr_subscr_with_vpcsc.number}",
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
    # Allow subscribers (VPC users) in var.subscr_vpc_sc_access_level_corp_allowed_identities from the jumphost located in the subscriber seed project 
    # required for the jumphost in the seed project to be able to subscribe to listing / create linked dataset in the target subscriber project
    {
      "from" = {
        "sources" = {
          access_levels = []
          resources = [ "projects/${data.google_project.subscr_seed_project.number}" ]
        },
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.subscr_subscr_with_vpcsc.number}",
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
#    # OPTIONAL - Allow egress to bq_src_ds (Google Service -> Google Service)
#    # OPTIONAL - required for querying src_ds from the (normal; non-authorized) view in shared_ds
#    # OPTIONAL - this is NOT needed for AUTHORIZED views after allowlisting for VPC-SC optimizations (contact Sales)
#    {
#      "from" = {
#        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
#        "sources" = {}
#      }
#      "to" = {
#        "resources" = [
#          "projects/${var.publ_project_number_bq_src_ds}",
#        ]
#        "operations" = {
#          "bigquery.googleapis.com" = {
#            "methods" = [
#              "*",
#            ]
#          }
#        }
#      }
#    },
    # Allow egress to ah_exchg,bq_and_ah (Google Service -> Google Service)
    # required for subscribing to the listing
    {
      "from" = {
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
        "sources" = {}
      }
      "to" = {
        "resources" = [
          "projects/${var.publ_project_number_ah_exchg}",
          "projects/${var.publ_project_number_bq_and_ah}",
          "projects/${var.publ_project_number_nonvpcsc_ah_exchg}",
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
  version = "~> 6.0.0"

  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "ahdemo_${var.name_suffix}_subscr_with_vpcsc_perimeter"
  description    = "ahdemo_${var.name_suffix}_subscr_with_vpcsc_perimeter"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.subscr_subscr_with_vpcsc.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.subscr_subscr_with_vpcsc.number ] : []

  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_subscriber_perimeter
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_subscriber_perimeter : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_subscriber_perimeter
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_subscriber_perimeter : []
}
