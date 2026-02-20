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

resource "google_access_context_manager_service_perimeter" "publ_only_ah" {
    title                     = "ahdemo_${var.name_suffix}_publ_only_ah"
    description               = "ahdemo_${var.name_suffix}_publ_only_ah"
    name                      = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}/servicePerimeters/ahdemo_${var.name_suffix}_publ_only_ah"
    parent                    = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}"
    perimeter_type            = "PERIMETER_TYPE_REGULAR"
    use_explicit_dry_run_spec = false

    status {
        access_levels       = []
        resources           = var.vpc_sc_dry_run ? [] : [ "projects/${data.google_project.publ_ah_exchg.number}" ]
        restricted_services = [
            "analyticshub.googleapis.com",
            "bigquery.googleapis.com",
            "bigquerydatapolicy.googleapis.com",
            "datacatalog.googleapis.com",
        ]
    }
  lifecycle {
    ignore_changes = [
      status[0].egress_policies,
      status[0].ingress_policies
      ] # Allows egress and ingress policies to be managed by google_access_context_manager_service_perimeter_egress_policy resources
  }
}

# Allow off-perimeter subscribers (Cloud Console users / end user accounts) from anywhere
# Public: required for subscribing to the public listing (allAuthenticatedUsers or allUsers => subscriber identity not known => ANY_IDENTITY)
# Private: required for subscribing to the private listing (subscriber identity known => gathered upon contracting => in var.publ_vpc_sc_ah_subscriber_identities)
resource "google_access_context_manager_service_perimeter_ingress_policy" "publ_only_ah_ingress_policy_0" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_only_ah.name}"

  title = "Ingress Policy 0"

  ingress_from {
      identities    = var.publ_vpc_sc_allow_all_for_public_listing ? [] : toset([for each in var.publ_vpc_sc_ah_subscriber_identities : each if startswith(each, "user")])
      identity_type = var.publ_vpc_sc_allow_all_for_public_listing ? "ANY_IDENTITY" : null

      sources {
          access_level = google_access_context_manager_access_level.access_level_allow_all.id
          resource     = null
      }
  }

  ingress_to {
      resources = [
          "*",
#          "projects/${data.google_project.publ_ah_exchg.number}",
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
# THIS SHOULD WORK - but it does not, hence the wildcard
#            "permissions" = [
#              "bigquery.datasets.create",
#            ]
#            "methods" = [
#              "DatasetService.InsertDataset",
#            ]
          }
      }
  }
}

# Allow off-perimeter internal users (Cloud Console users) in var.publ_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
# required for the (internal) admins to manage BQ / AH
resource "google_access_context_manager_service_perimeter_ingress_policy" "publ_only_ah_ingress_policy_1" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_only_ah.name}"

  title = "Ingress Policy 1"

  ingress_from {
      identities    = var.publ_vpc_sc_access_level_corp_allowed_identities
      identity_type = null

      sources {
          access_level = google_access_context_manager_access_level.access_level_allow_corp.id
          resource     = null
      }
  }

  ingress_to {
      resources = [
          "*",
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

# Allow off-perimeter subscribers (service accounts) in var.publ_vpc_sc_ah_subscriber_identities from specific subscriber projects
# required for subscribing to the private listing using a jumphost (subscriber identity known => gathered upon contracting)
# this is an alternative to access_level based allow_all for Cloud Console / external users: project based allow to subscribe via API call from a jumphost
resource "google_access_context_manager_service_perimeter_ingress_policy" "publ_only_ah_ingress_policy_2" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_only_ah.name}"

  title = "Ingress Policy 2"

  ingress_from {
      identities    = toset([for each in var.publ_vpc_sc_ah_subscriber_identities : each if startswith(each, "serviceAccount")])
      identity_type = null

      sources {
          access_level = google_access_context_manager_access_level.access_level_allow_all.id
          resource     = null
      }
      sources {
          access_level = null
          resource     = "projects/${var.subscr_project_number_seed}"
      }
      sources {
          access_level = null
          resource     = "projects/${var.subscr_project_number_subscr_with_vpcsc}"
      }
      sources {
          access_level = null
          resource     = "projects/${var.subscr_project_number_subscr_without_vpcsc}"
      }
      sources {
          access_level = null
          resource     = "projects/${var.subscr_project_number_subscr_xpn}"
      }
#      sources {
#          access_level = null
#          resource     = "projects/${var.subscr_project_number_subscr_vm}"
#      }
  }

  ingress_to {
      resources = [
          "*",
#          "projects/${data.google_project.publ_ah_exchg.number}",
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
# THIS SHOULD WORK - but it does not, hence the wildcard
#            "permissions" = [
#              "bigquery.datasets.create",
#            ]
#            "methods" = [
#              "DatasetService.InsertDataset",
#            ]
          }
      }
  }
}

# Allow egress to all / specific projects (Google Service -> Google Service)
# Public: required for subscribing to the public listing (allAuthenticatedUsers or allUsers => subscriber identity not known => ANY_IDENTITY) (To all projects, as project is unknown)
# Private: Private: required for subscribing to the private listing (subscriber identity known => gathered from the subscriber) (To specific projects, gathered from the subscriber)
resource "google_access_context_manager_service_perimeter_egress_policy" "publ_only_ah_egress_policy_0" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_only_ah.name}"

  title = "Egress Policy 0"

  egress_from {
      identities         = var.publ_vpc_sc_allow_all_for_public_listing ? [] : var.publ_vpc_sc_ah_subscriber_identities
      identity_type      = var.publ_vpc_sc_allow_all_for_public_listing ? "ANY_IDENTITY" : null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = var.publ_vpc_sc_allow_all_for_public_listing ? [ "*" ] : local.vpc_sc_ah_subscriber_project_resources_with_numbers
      roles              = []

      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = null
              permission = "bigquery.datasets.create"
          }
      }
  }
}

# Allow egress to bq_shared_ds (Google Service -> Google Service)
# required for creating the listing
resource "google_access_context_manager_service_perimeter_egress_policy" "publ_only_ah_egress_policy_1" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_only_ah.name}"

  title = "Egress Policy 1"

  egress_from {
      identities         = var.publ_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${data.google_project.publ_bq_shared_ds.number}",
        ]
        "operations" = {
          "bigquery.googleapis.com" = {
            "permissions" = [
            ]
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
  version = "7.2.0"

  policy         = google_access_context_manager_access_policy.access_policy.id
  perimeter_name = "ahdemo_${var.name_suffix}_publ_only_ah"
  description    = "ahdemo_${var.name_suffix}_publ_only_ah"

  restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  restricted_services_dry_run = var.vpc_sc_dry_run ? var.vpc_sc_restricted_services : []

  access_levels = []

  resources = var.vpc_sc_dry_run ? [] : [ data.google_project.publ_ah_exchg.number ]
  resources_dry_run = var.vpc_sc_dry_run ? [ data.google_project.publ_ah_exchg.number ] : []

  ingress_policies = var.vpc_sc_dry_run ? [] : local.ingress_policies_ah_perimeter
  ingress_policies_dry_run = var.vpc_sc_dry_run ? local.ingress_policies_ah_perimeter : []
  egress_policies = var.vpc_sc_dry_run ? [] : local.egress_policies_ah_perimeter
  egress_policies_dry_run = var.vpc_sc_dry_run ? local.egress_policies_ah_perimeter : []
}
