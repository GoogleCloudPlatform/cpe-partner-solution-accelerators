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
          },
          "bigquerydatapolicy.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
          "datacatalog.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
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

  # OPTIONAL - Allow egress to bq_src_ds (Google Service -> Google Service)
  # OPTIONAL - required for querying src_ds from the (normal; non-authorized) view in shared_ds
  # OPTIONAL - this is NOT needed for AUTHORIZED views after allowlisting for VPC-SC optimizations (contact Sales)
  egress_policy_subscriber_src_ds = {
      "from" = {
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "projects/${var.publ_project_number_bq_src_ds}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          }
        }
      }
    }

  egress_policies_subscriber_perimeter = concat(
    var.publ_allowlisted_vpcsc_opt ? [] : [local.egress_policy_subscriber_src_ds],
    [
    # Allow egress to ah_exchg,bq_and_ah (Google Service -> Google Service)
    # required for subscribing to the listing
    {
      "from" = {
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
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
          },
        }
      }
    },
    # Allow egress to subscr_with_vpcsc,subscr_without_vpcsc (Google Service -> Google Service)
    # When only the shared VPC network is part of the VPC-SC perimeter (and not the service and host projects themselves): required for subscribing to the listing from a jumphost attached to the shared VPC
    {
      "from" = {
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "projects/${var.subscr_project_number_subscr_with_vpcsc}",
          "projects/${var.subscr_project_number_subscr_without_vpcsc}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
        }
      }
    },
    # Allow egress to ah_exchg,bq_and_ah,nonvpcsc_ah_exchg (Google Service -> Google Service)
    # When the host and service projects are part of the VPC-SC perimeter (and not the network itself): required for subscribing to the listing from a jumphost within the perimeter (projects -xpn -vm)
    {
      "from" = {
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "projects/${var.publ_project_number_ah_exchg}",
          "projects/${var.publ_project_number_bq_and_ah}",
          "projects/${var.publ_project_number_nonvpcsc_ah_exchg}",
        ]
        "operations" = {
          "analyticshub.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
        }
      }
    },
    # Allow egress to bq_shared_ds,bq_src_ds (Google Service -> Google Service)
    # required for querying columns with policy tags
    {
      "from" = {
        "identities" = var.subscr_vpc_sc_access_level_corp_allowed_identities
      }
      "to" = {
        "resources" = [
          "projects/${var.publ_project_number_bq_shared_ds}",
          "projects/${var.publ_project_number_bq_src_ds}",
          "projects/${var.publ_project_number_bq_and_ah}",
        ]
        "operations" = {
          "bigquerydatapolicy.googleapis.com" = {
            "methods" = [
              "*",
            ]
          },
          "bigquery.googleapis.com" = {
            "methods" = [
            ]
            "permissions" = [
              "datacatalog.categories.fineGrainedGet"
            ]
          },
        }
      }
    },
  ])
}

module "regular_service_perimeter_subscr_with_vpcsc" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "7.0.0"

  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "ahdemo_${var.name_suffix}_subscr_with_vpcsc_perimeter"
  description    = "ahdemo_${var.name_suffix}_subscr_with_vpcsc_perimeter"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.subscr_subscr_with_vpcsc.number, data.google_project.subscr_subscr_xpn.number, data.google_project.subscr_subscr_vm.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.subscr_subscr_with_vpcsc.number, data.google_project.subscr_subscr_xpn.number, data.google_project.subscr_subscr_vm.number ] : []
#  For testing from Shared VPC host and service projects
#  resources = var.vpc_sc_dry_run ? [] : [ replace(google_compute_network.vpc_network_xpn.self_link, "https://www.googleapis.com/compute/v1/", "") ]
#  resources_dry_run = var.vpc_sc_dry_run ? [ replace(google_compute_network.vpc_network_xpn.self_link, "https://www.googleapis.com/compute/v1/", "") ] : []

  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_subscriber_perimeter
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_subscriber_perimeter : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_subscriber_perimeter
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_subscriber_perimeter : []
}
