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

# Override Domain restricted sharing
resource "google_org_policy_policy" "override_drs" {
  parent = "organizations/${var.prov_org_id}"
  name   = "organizations/${var.prov_org_id}/policies/iam.allowedPolicyMemberDomains"

  spec {
    inherit_from_parent = false

    rules {
      values {
        allowed_values = var.drs_allowed_domains
        denied_values = []
      }
    }
  }
}

locals {
  dns_domain_name_trimmed = trim(var.dns_domain_name, ".")
}

# Override Allowed external Identity Providers for workloads in Cloud IAM
resource "google_org_policy_policy" "override_wipool" {
  parent = "organizations/${var.prov_org_id}"
  name   = "organizations/${var.prov_org_id}/policies/iam.workloadIdentityPoolProviders"

  spec {
    inherit_from_parent = false

    rules {
      values {
        allowed_values = [
            "https://keycloak.${local.dns_domain_name_trimmed}/realms/google"
          ]
      }
    }
  }
}
