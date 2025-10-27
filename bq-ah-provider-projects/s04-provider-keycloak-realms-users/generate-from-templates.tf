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
  templates = {
    "environment_keycloak.sh" = "environment_keycloak.sh.tpl",
  }
}

resource "local_file" "generated" {
  for_each = local.templates

  content  = templatefile("${path.module}/../templates/${each.value}",
    {
      google_wloadif_client_id = keycloak_openid_client.google_wloadif_client.client_id,
      google_wloadif_client_scope = keycloak_openid_client_scope.google_wloadif_client_scope.name,
      google_wloadif_client_secret = keycloak_openid_client.google_wloadif_client.client_secret,
      google_wloadif_aud = keycloak_openid_audience_protocol_mapper.google_wloadif_audience_mapper.included_custom_audience,
      google_wfif_client_id = keycloak_openid_client.google_wfif_client.client_id,
      google_wfif_client_scope = keycloak_openid_client_scope.google_wfif_client_scope.name,
      google_wfif_client_secret = keycloak_openid_client.google_wfif_client.client_secret,
      google_wfif_aud = "//iam.googleapis.com/locations/global/workforcePools/${var.wlwfif_pool_name}/providers/${var.wlwfif_provider_name}"
      user_password = random_password.test_user_pw.result,
      project_number_idp = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.project_number_idp,
    }
  )
  filename = "${path.module}/../generated/${each.key}"
  file_permission = 0600
}
