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


resource "google_access_context_manager_access_policy" "access_policy" {
    parent = "organizations/${var.publ_vpc_sc_policy_parent_org_id}"
    title  = "ahdemo-cx-scoped-policy"
    scopes = [ format("projects/%s", google_project.publ_cs_cx_foo_project.number) ]
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/accesscontextmanager.policyAdmin"
    members = [
      "user:${var.gcloud_user}",
      "serviceAccount:${var.publ_terraform_sa_email}",
    ]
  }
}

resource "google_access_context_manager_access_policy_iam_policy" "policy" {
  name = google_access_context_manager_access_policy.access_policy.name
  policy_data = data.google_iam_policy.admin.policy_data
}

resource "google_access_context_manager_service_perimeter" "cs_perimeter" {
  parent         = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}"
  name           = "accessPolicies/${google_access_context_manager_access_policy.access_policy.name}/servicePerimeters/ahdemo_test"
  title          = "ahdemo_test"
  perimeter_type = "PERIMETER_TYPE_REGULAR"

  status {
    resources = [
      format("projects/%s", google_project.publ_cs_cx_foo_project.number)
    ]

    restricted_services = [
      "bigquery.googleapis.com",
      "storage.googleapis.com"
      ]
    access_levels       = []

    vpc_accessible_services {
      enable_restriction = true
      allowed_services   = [
        "RESTRICTED-SERVICES",
        "compute.googleapis.com",
        "confidentialcomputing.googleapis.com",
        "iam.googleapis.com",
        "securetoken.googleapis.com",
        "sts.googleapis.com",
      ]
    }

    ingress_policies {
      ingress_from {
        sources {
            access_level = "*"
        }
        identity_type = "ANY_IDENTITY"
      }
    }
    egress_policies {
      egress_from {
        identities    = []
        identity_type = "ANY_IDENTITY"
      }

      egress_to {
        resources = [ "projects/836012687317" ]
        operations {
          service_name = "bigquery.googleapis.com"

          method_selectors {
            method = "BigQueryStorage.ReadRows"
          }
          method_selectors {
            method = "TableService.ListTables"
          }
          method_selectors {
            method = "TableService.GetTable"
          }
          method_selectors {
            method = "BigQueryRead.ReadRows"
          }

          method_selectors {
            permission = "bigquery.tables.getData"
          }
# This is needed for writes
#                    method_selectors {
#                        permission = "bigquery.tables.updateData"
#                    }
          method_selectors {
            permission = "bigquery.tables.get"
          }
          method_selectors {
            permission = "bigquery.tables.list"
          }
        }
      }
    }
  }
}
