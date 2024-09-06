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

resource "google_iam_workload_identity_pool" "keycloak" {
  workload_identity_pool_id = "${var.wlwfif_pool_name}"
  display_name              = "${var.wlwfif_pool_name}"
  description               = "${var.wlwfif_pool_name}"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "keycloak" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.keycloak.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wlwfif_provider_name
  display_name = var.wlwfif_provider_name
  attribute_mapping                  = {
    "google.subject" = "assertion.sub",
    "attribute.aud" = "assertion.aud"
  }
  oidc {
    issuer_uri        = "https://keycloak.${local.dns_name_trimmed}/realms/google"
    allowed_audiences = [
      "//iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.wlwfif_pool_name}/providers/${var.wlwfif_provider_name}",
      "google-wloadif-client",
    ]
  }
}
