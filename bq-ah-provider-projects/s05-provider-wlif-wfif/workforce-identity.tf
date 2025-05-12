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

resource "google_iam_workforce_pool" "keycloak" {
  workforce_pool_id   = "${var.wlwfif_pool_name}"
  parent              = "organizations/${var.prov_org_id}"
  location            = "global"
  display_name        = "${var.wlwfif_pool_name}"
  description         = "${var.wlwfif_pool_name}"
  disabled            = false
  session_duration    = "7200s"
}

resource "google_iam_workforce_pool_provider" "keycloak" {
  workforce_pool_id          = google_iam_workforce_pool.keycloak.workforce_pool_id
  location            = "global"
  provider_id = "${var.wlwfif_provider_name}"
  display_name = "${var.wlwfif_provider_name}"
  attribute_mapping                  = {
    "google.subject" = "assertion.sub",
    "google.display_name" = "assertion.preferred_username",
    "attribute.aud" = "assertion.aud"
  }
  oidc {
    issuer_uri        = "https://keycloak.${local.dns_name_trimmed}/realms/google"
    client_id        = data.terraform_remote_state.keycloak.outputs.wfif_client_id
    client_secret {
      value {
        plain_text = data.terraform_remote_state.keycloak.outputs.wfif_client_secret
      }
    }
    web_sso_config {
      response_type             = "CODE"
      assertion_claims_behavior = "MERGE_USER_INFO_OVER_ID_TOKEN_CLAIMS"
    }
  }
}
