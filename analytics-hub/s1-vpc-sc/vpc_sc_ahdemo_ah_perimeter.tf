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
  ingress_policies_ah_perimeter = [
    # Allow off-perimeter internal users (Cloud Console users) in var.vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_corp.name ] # Allow access from corporate network IP ranges
        },
        "identities" = var.vpc_sc_access_level_corp_allowed_identities
        "identity_type" = null
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.ah_exchg.number}",
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
    # Allow off-perimeter public subscribers (Cloud Console users) from anywhere - required for subscribing to the public listing
    var.vpc_sc_allow_all_for_public_listing ? {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_all.name ] # Allow access from everywhere
        },
        "identities" = []
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.ah_exchg.number}",
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
    } :
    # Allow off-perimeter subscribers (Cloud Console users) in var.vpc_sc_ah_subscriber_identities from anywhere - required for subscribing to the listing
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_all.name ] # Allow access from everywhere
        },
        "identities" = var.vpc_sc_ah_subscriber_identities
        "identity_type" = null
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.ah_exchg.number}",
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

  egress_policies_ah_perimeter = [
    # Allow egress to all projects (Google Service -> Google Service) - required for subscribing to the public listing
    var.vpc_sc_allow_all_for_public_listing ? {
      "from" = {
        "identities" = []
        "identity_type" = "ANY_IDENTITY"
      }
      "to" = {
        "resources" = [ "*" ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    } :
    # Allow egress to #subscriber_project_number (Google Service -> Google Service) - required for subscribing to the listing
    {
      "from" = {
        "identities" = var.vpc_sc_ah_subscriber_identities
        "identity_type" = null
      }
      "to" = {
        "resources" = local.vpc_sc_ah_subscriber_project_resources_with_numbers
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    },
    # Allow egress to bq_shared_ds (Google Service -> Google Service) - required for creating the listing
    {
      "from" = {
        "identities" = var.vpc_sc_access_level_corp_allowed_identities
        "identity_type" = null
      }
      "to" = {
        "resources" = [
          "projects/${data.google_project.bq_shared_ds.number}",
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

module "regular_service_perimeter_ah" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 5.2.1"

  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "ahdemo_${var.name_suffix}_ah_perimeter"
  description    = "ahdemo_${var.name_suffix}_ah_perimeter"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.ah_exchg.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.ah_exchg.number ] : []

  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_ah_perimeter
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_ah_perimeter : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_ah_perimeter
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_ah_perimeter : []
}
