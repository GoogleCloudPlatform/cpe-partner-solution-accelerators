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
  ingress_policies_bq_perimeter_src_ds = [
    # Allow off-perimeter internal users (Cloud Console users) in var.publ_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
    # required for the (internal) admins to manage BQ / AH
    {
      "from" = {
        "sources" = {
          access_levels = [ module.access_level_allow_corp.name ] # Allow access from corporate network IP ranges
        },
        "identities" = var.publ_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "*",
#          "projects/${data.google_project.publ_bq_src_ds.number}",
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
#    # OPTIONAL - Allow off-perimeter subscribers (Cloud Console users) in var.publ_vpc_sc_ah_subscriber_identities from anywhere
#    # OPTIONAL - required for querying src_ds from the (normal; non-authorized) view in shared_ds
#    # OPTIONAL - this is NOT needed for AUTHORIZED views after allowlisting for VPC-SC optimizations (b/325278068)
#    {
#      "from" = {
#        "sources" = {
#          access_levels = [ module.access_level_allow_all.name ] # Allow access from everywhere
#        },
#        "identities" = var.publ_vpc_sc_ah_subscriber_identities
#      }
#      "to" = {
#        "resources" = [
#          "*"
##          "projects/${data.google_project.publ_ah_exchg.number}",
#        ]
#        "operations" = {
#          "bigquery.googleapis.com" = {
#            "permissions" = [
#              "bigquery.tables.getData"
#            ]
#            "methods" = [
#            ]
#          }
#        }
#      }
#    },
  ]

  egress_policies_bq_perimeter_src_ds = [
    # Allow egress to bq_shared_ds and bq_and_ah (Google Service -> Google Service)
    # required for creating the view from shared_ds/bq_and_ah to src_ds
    {
      "from" = {
        "identities" = var.publ_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "projects/${data.google_project.publ_bq_shared_ds.number}",
          "projects/${data.google_project.publ_bq_and_ah.number}",
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
#    # OPTIONAL - Allow egress to #subscriber_project_number (Google Service -> Google Service)
#    # OPTIONAL - required for querying src_ds from the (normal; non-authorized) view in shared_ds
#    # OPTIONAL - this is NOT needed for AUTHORIZED views after allowlisting for VPC-SC optimizations (contact Sales)
#    {
#      "from" = {
#        "identities" = var.publ_vpc_sc_ah_subscriber_identities
#      }
#      "to" = {
#        "resources" = local.vpc_sc_ah_subscriber_project_resources_with_numbers
#        "operations" = {
#          "bigquery.googleapis.com" = {
#            "permissions" = [
#              "bigquery.tables.getData",
#              "bigquery.jobs.create"
#            ]
#            "methods" = [
#            ]
#          }
#        }
#      }
#    },
  ]
}

module "regular_service_perimeter_bq_src_ds" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 5.2.1"

  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "ahdemo_${var.name_suffix}_publ_bq_src_ds"
  description    = "ahdemo_${var.name_suffix}_publ_bq_src_ds"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.publ_bq_src_ds.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.publ_bq_src_ds.number ] : []

  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_bq_perimeter_src_ds
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_bq_perimeter_src_ds : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_bq_perimeter_src_ds
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_bq_perimeter_src_ds : []
}
