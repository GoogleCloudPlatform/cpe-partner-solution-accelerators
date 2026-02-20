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

resource "google_access_context_manager_service_perimeter" "publ_bq_src_ds" {
  title                     = "ahdemo_${var.name_suffix}_publ_bq_src_ds"
  description               = "ahdemo_${var.name_suffix}_publ_bq_src_ds"
  name                      = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}/servicePerimeters/ahdemo_${var.name_suffix}_publ_bq_src_ds"
  parent                    = "accessPolicies/${google_access_context_manager_access_policy.access_policy.id}"
  perimeter_type            = "PERIMETER_TYPE_REGULAR"
  use_explicit_dry_run_spec = false

  status {
      access_levels       = []
      resources           = var.vpc_sc_dry_run ? [] : [ "projects/${data.google_project.publ_bq_src_ds.number}" ]
      restricted_services = var.vpc_sc_dry_run ? [] : var.vpc_sc_restricted_services
  }

  lifecycle {
    ignore_changes = [
      status[0].egress_policies,
      status[0].ingress_policies
      ] # Allows egress and ingress policies to be managed by google_access_context_manager_service_perimeter_egress_policy resources
  }
}

# Allow off-perimeter internal users (Cloud Console users) in var.publ_vpc_sc_access_level_corp_allowed_identities from the corporate network IP ranges
# required for the (internal) admins to manage BQ / AH
resource "google_access_context_manager_service_perimeter_ingress_policy" "publ_bq_src_ds_ingress_policy_0" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_bq_src_ds.name}"

  title = "Ingress Policy 0"

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
          "*", # "projects/${data.google_project.publ_bq_src_ds.number}"
      ]
      roles     = []

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

# Allow off-perimeter subscribers (Cloud Console users) from anywhere
# Public: required for querying columns with policy tags in the public listing (allAuthenticatedUsers or allUsers => subscriber identity not known => ANY_IDENTITY)
# Private: required for querying columns with policy tags in the private listing (subscriber identity known => gathered upon contracting => in var.publ_vpc_sc_ah_subscriber_identities)
resource "google_access_context_manager_service_perimeter_ingress_policy" "publ_bq_src_ds_ingress_policy_1" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_bq_src_ds.name}"

  title = "Ingress Policy 1"

  ingress_from {
      identities    = var.publ_vpc_sc_allow_all_for_public_listing ? [] : var.publ_vpc_sc_ah_subscriber_identities
      identity_type = var.publ_vpc_sc_allow_all_for_public_listing ? "ANY_IDENTITY" : null

      sources {
          access_level = google_access_context_manager_access_level.access_level_allow_all.id
          resource     = null
      }
  }

  ingress_to {
      resources = [
          "*", # "projects/${data.google_project.publ_bq_shared_ds.number}"
      ]
      roles     = []

      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = null
              permission = "datacatalog.categories.fineGrainedGet"
          }
      }
      operations {
          service_name = "bigquerydatapolicy.googleapis.com"

          method_selectors {
              method     = "*"
              permission = null
          }
      }
  }
}

# OPTIONAL - Allow off-perimeter subscribers (Cloud Console users) in var.publ_vpc_sc_ah_subscriber_identities from anywhere
# OPTIONAL - required for querying src_ds from the (normal; non-authorized) view in shared_ds
# OPTIONAL - this is NOT needed for AUTHORIZED views after allowlisting for VPC-SC optimizations (contact Sales)
resource "google_access_context_manager_service_perimeter_ingress_policy" "publ_bq_src_ds_ingress_policy_2" {
  count = var.publ_allowlisted_vpcsc_opt ? 0 : 1

  perimeter = "${google_access_context_manager_service_perimeter.publ_bq_src_ds.name}"

  title = "Ingress Policy 2"

  ingress_from {
      identities    = concat(var.publ_vpc_sc_ah_subscriber_identities, var.subscr_subscriber_projects_bq_readers_iam_members)
      identity_type = null

      sources {
          access_level = google_access_context_manager_access_level.access_level_allow_all.id
          resource     = null
      }
  }

  ingress_to {
      resources = [
          "*", # "projects/${data.google_project.publ_ah_exchg.number}"
      ]
      roles     = []

      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = null
              permission = "bigquery.tables.getData"
          }
      }
  }
}

# Allow egress to bq_shared_ds and bq_and_ah (Google Service -> Google Service)
# required for creating the view from shared_ds/bq_and_ah to src_ds
resource "google_access_context_manager_service_perimeter_egress_policy" "publ_bq_src_ds_egress_policy_0" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_bq_src_ds.name}"

  title = "Egress Policy 0"

  egress_from {
      identities         = var.publ_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${data.google_project.publ_bq_shared_ds.number}",
          "projects/${data.google_project.publ_bq_and_ah.number}",
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

# Allow egress to bq_fed_ds (Google Service -> Google Service)
# required for creating the view from src_ds to fed_ds
resource "google_access_context_manager_service_perimeter_egress_policy" "publ_bq_src_ds_egress_policy_1" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_bq_src_ds.name}"

  title = "Egress Policy 1"

  egress_from {
      identities         = var.publ_vpc_sc_access_level_corp_allowed_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = [
          "projects/${data.google_project.publ_bq_fed_ds.number}",
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

# Allow egress to #subscriber_project_number (Google Service -> Google Service)
# required for querying columns with privacy tags in src_ds from the subscriber projects
resource "google_access_context_manager_service_perimeter_egress_policy" "publ_bq_src_ds_egress_policy_2" {
  perimeter = "${google_access_context_manager_service_perimeter.publ_bq_src_ds.name}"

  title = "Egress Policy 2"

  egress_from {
      identities         = var.publ_vpc_sc_ah_subscriber_identities
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = local.vpc_sc_ah_subscriber_project_resources_with_numbers
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
          method_selectors {
              method     = null
              permission = "bigquery.jobs.create"
          }
      }
  }
}

# OPTIONAL - Allow egress to #subscriber_project_number (Google Service -> Google Service)
# OPTIONAL - required for querying src_ds from the (normal; non-authorized) view in shared_ds
# OPTIONAL - this is NOT needed for AUTHORIZED views after allowlisting for VPC-SC optimizations (contact Sales)
resource "google_access_context_manager_service_perimeter_egress_policy" "publ_bq_src_ds_egress_policy_3" {
  count = var.publ_allowlisted_vpcsc_opt ? 0 : 1

  perimeter = "${google_access_context_manager_service_perimeter.publ_bq_src_ds.name}"

  title = "Egress Policy 3"

  egress_from {
      identities         = concat(var.publ_vpc_sc_ah_subscriber_identities, var.subscr_subscriber_projects_bq_readers_iam_members)
      identity_type      = null
      source_restriction = "SOURCE_RESTRICTION_DISABLED"
  }

  egress_to {
      external_resources = []
      resources          = local.vpc_sc_ah_subscriber_project_resources_with_numbers
      roles              = []

      operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
              method     = null
              permission = "bigquery.tables.getData"
          }
          method_selectors {
              method     = null
              permission = "bigquery.jobs.create"
          }
      }
  }
}
