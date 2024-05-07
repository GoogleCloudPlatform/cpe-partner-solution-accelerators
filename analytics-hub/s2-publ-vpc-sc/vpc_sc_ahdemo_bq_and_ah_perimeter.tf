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

  ingress_policies_bq_and_ah_perimeter = [
    # Allow off-perimeter internal users (Cloud Console users) in var.publ_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
    # required for the (internal) admins to manage BQ / AH
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_corp.name ] # Allow access from corporate network IP ranges
        },
        "identities" = var.publ_vpc_sc_access_level_corp_allowed_identities
        "identity_type" = null
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.publ_bq_and_ah.number}",
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
    # Allow off-perimeter subscribers (Cloud Console users) from anywhere
    # Public: required for subscribing to the public listing (allAuthenticatedUsers or allUsers => subscriber identity not known => ANY_IDENTITY)
    # Private: required for subscribing to the private listing (subscriber identity known => gathered upon contracting => in var.publ_vpc_sc_ah_subscriber_identities)
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_all.name ] # Allow access from everywhere ( "*" works as well)
        },
        "identities" = var.publ_vpc_sc_allow_all_for_public_listing ? [] : var.publ_vpc_sc_ah_subscriber_identities
        "identity_type" = var.publ_vpc_sc_allow_all_for_public_listing ? "ANY_IDENTITY" : null
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.publ_bq_and_ah.number}",
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
          },
        }
      }
    },
  ]

  egress_policies_bq_and_ah_perimeter = [
    # Allow egress to all / specific projects (Google Service -> Google Service)
    # Public: required for subscribing to the public listing (allAuthenticatedUsers or allUsers => subscriber identity not known => ANY_IDENTITY) (To all projects, as project is unknown)
    # Private: Private: required for subscribing to the private listing (subscriber identity known => gathered from the subscriber) (To specific projects, gathered from the subscriber)
    {
      "from" = {
        "identities" = var.publ_vpc_sc_allow_all_for_public_listing ? [] : var.publ_vpc_sc_ah_subscriber_identities
        "identity_type" = var.publ_vpc_sc_allow_all_for_public_listing ? "ANY_IDENTITY" : null
      }
      "to" = {
        "resources" = var.publ_vpc_sc_allow_all_for_public_listing ? [ "*" ] : local.vpc_sc_ah_subscriber_project_resources_with_numbers
        "operations" = {
          "bigquery.googleapis.com" = {
            "permissions" = [
              "bigquery.datasets.create",
            ]
            "methods" = []
          }
        }
      }
    },
    # Allow egress to bq_src_ds (Google Service -> Google Service)
    # required for creating the view from bq_and_ah to src_ds
    {
      "from" = {
        "identities" = var.publ_vpc_sc_access_level_corp_allowed_identities
        "identity_type" = null
      }
      "to" = {
        "resources" = [
          "projects/${data.google_project.publ_bq_src_ds.number}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "permissions" = [
            ],
            "methods" = [
              "*",
            ]
          }
        }
      }
    },
  ]
}

module "regular_service_perimeter_bq_and_ah" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 5.2.1"

  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "ahdemo_${var.name_suffix}_publ_bq_and_ah"
  description    = "ahdemo_${var.name_suffix}_publ_bq_and_ah"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.publ_bq_and_ah.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.publ_bq_and_ah.number ] : []

  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_bq_and_ah_perimeter
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_bq_and_ah_perimeter : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_bq_and_ah_perimeter
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_bq_and_ah_perimeter : []
}
