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

resource "google_access_context_manager_service_perimeter" "subscr_with_vpcsc_perimeter" {
  title                     = "ahdemo_${var.name_suffix}_subscr_with_vpcsc_perimeter"
  description               = "ahdemo_${var.name_suffix}_subscr_with_vpcsc_perimeter"
  name                      = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}/servicePerimeters/ahdemo_${var.name_suffix}_subscr_with_vpcsc_perimeter"
  parent                    = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}"
  perimeter_type            = "PERIMETER_TYPE_REGULAR"
  use_explicit_dry_run_spec = false

  status {
      access_levels       = []
      resources           = var.vpc_sc_dry_run ? [] : [ 
        "projects/${data.google_project.subscr_subscr_with_vpcsc.number}", 
        "projects/${data.google_project.subscr_subscr_xpn.number}", 
        "projects/${data.google_project.subscr_subscr_vm.number}" ]
      restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  }

  lifecycle {
    ignore_changes = [
      status[0].egress_policies,
      status[0].ingress_policies
      ] # Allows egress and ingress policies to be managed by google_access_context_manager_service_perimeter_egress_policy resources
  }
}

# Allow off-perimeter internal users including subscribers (Cloud Console users) in var.subscr_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
# required for the (internal) admins / subscribers to manage BQ / AH
resource "google_access_context_manager_service_perimeter_ingress_policy" "subscr_with_vpcsc_perimeter_ingress_policy_0" {
  perimeter = "${google_access_context_manager_service_perimeter.subscr_with_vpcsc_perimeter.name}"

  title = "Ingress Policy 0"

  ingress_from {
      identities    = var.subscr_vpc_sc_access_level_corp_allowed_identities

      sources {
          access_level = google_access_context_manager_access_level.access_level_allow_all.id
          resource     = null
      }
  }

  ingress_to {
      resources = [
          "*", # "projects/${data.google_project.subscr_subscr_with_vpcsc.number}"
      ]
      roles     = []

      operations {
          service_name = "analyticshub.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
      operations {
          service_name = "bigquerydatapolicy.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
      operations {
          service_name = "datacatalog.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
  }
}

# Allow subscribers (VPC users) in var.subscr_vpc_sc_access_level_corp_allowed_identities from the jumphost located in the subscriber seed project 
# required for the jumphost in the seed project to be able to subscribe to listing / create linked dataset in the target subscriber project
resource "google_access_context_manager_service_perimeter_ingress_policy" "subscr_with_vpcsc_perimeter_ingress_policy_1" {
  perimeter = "${google_access_context_manager_service_perimeter.subscr_with_vpcsc_perimeter.name}"

  title = "Ingress Policy 1"

  ingress_from {
      identities    = var.subscr_vpc_sc_access_level_corp_allowed_identities

      sources {
          access_level = null
          resource     = "projects/${data.google_project.subscr_seed_project.number}"
      }
  }

  ingress_to {
      resources = [
          "*", # "projects/${data.google_project.subscr_subscr_with_vpcsc.number}"
      ]
      roles     = []

      operations {
          service_name = "analyticshub.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
  }
}

# Allow egress to ah_exchg,bq_and_ah (Google Service -> Google Service)
# required for subscribing to the listing
resource "google_access_context_manager_service_perimeter_egress_policy" "subscr_with_vpcsc_perimeter_egress_policy_0" {
  perimeter = "${google_access_context_manager_service_perimeter.subscr_with_vpcsc_perimeter.name}"

  title = "Egress Policy 0"

  egress_from {
      identities         = var.subscr_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${var.publ_project_number_ah_exchg}",
          "projects/${var.publ_project_number_bq_and_ah}",
          "projects/${var.publ_project_number_nonvpcsc_ah_exchg}",
        ]
      roles              = []

      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
  }
}

# Allow egress to subscr_with_vpcsc,subscr_without_vpcsc (Google Service -> Google Service)
# When only the shared VPC network is part of the VPC-SC perimeter (and not the service and host projects themselves): required for subscribing to the listing from a jumphost attached to the shared VPC
resource "google_access_context_manager_service_perimeter_egress_policy" "subscr_with_vpcsc_perimeter_egress_policy_1" {
  perimeter = "${google_access_context_manager_service_perimeter.subscr_with_vpcsc_perimeter.name}"

  title = "Egress Policy 1"

  egress_from {
      identities         = var.subscr_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${var.subscr_project_number_subscr_with_vpcsc}",
          "projects/${var.subscr_project_number_subscr_without_vpcsc}",
        ]
      roles              = []

      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
  }
}

# Allow egress to ah_exchg,bq_and_ah,nonvpcsc_ah_exchg (Google Service -> Google Service)
# When the host and service projects are part of the VPC-SC perimeter (and not the network itself): required for subscribing to the listing from a jumphost within the perimeter (projects -xpn -vm)
resource "google_access_context_manager_service_perimeter_egress_policy" "subscr_with_vpcsc_perimeter_egress_policy_2" {
  perimeter = "${google_access_context_manager_service_perimeter.subscr_with_vpcsc_perimeter.name}"

  title = "Egress Policy 2"

  egress_from {
      identities         = var.subscr_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${var.publ_project_number_ah_exchg}",
          "projects/${var.publ_project_number_bq_and_ah}",
          "projects/${var.publ_project_number_nonvpcsc_ah_exchg}",
        ]
      roles              = []

      operations {
          service_name = "analyticshub.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
  }
}

# Allow egress to bq_shared_ds,bq_src_ds (Google Service -> Google Service)
# required for querying columns with policy tags
resource "google_access_context_manager_service_perimeter_egress_policy" "subscr_with_vpcsc_perimeter_egress_policy_3" {
  perimeter = "${google_access_context_manager_service_perimeter.subscr_with_vpcsc_perimeter.name}"

  title = "Egress Policy 3"

  egress_from {
      identities         = var.subscr_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${var.publ_project_number_bq_shared_ds}",
          "projects/${var.publ_project_number_bq_src_ds}",
          "projects/${var.publ_project_number_bq_and_ah}",
        ]
      roles              = []

      operations {
          service_name = "bigquerydatapolicy.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = null
              permission = "datacatalog.categories.fineGrainedGet"
          }
      }
  }
}

# OPTIONAL - Allow egress to bq_src_ds (Google Service -> Google Service)
# OPTIONAL - required for querying src_ds from the (normal; non-authorized) view in shared_ds
# OPTIONAL - this is NOT needed for AUTHORIZED views after allowlisting for VPC-SC optimizations (contact Sales)
resource "google_access_context_manager_service_perimeter_egress_policy" "subscr_with_vpcsc_perimeter_egress_policy_4" {
  count = var.publ_allowlisted_vpcsc_opt ? 0 : 1

  perimeter = "${google_access_context_manager_service_perimeter.subscr_with_vpcsc_perimeter.name}"

  title = "Egress Policy 4"

  egress_from {
      identities         = var.subscr_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${var.publ_project_number_bq_src_ds}",
        ]
      roles              = []

      operations {
          service_name = "bigquerydatapolicy.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
  }
}
