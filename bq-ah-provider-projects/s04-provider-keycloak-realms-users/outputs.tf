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

output "user_password" {
  description = "User password"
  value       = random_password.test_user_pw.result
  sensitive = true
}
output "test_users" {
  description = "Test users"
  value = {
    "john": keycloak_user.user_john.id,
    "jane": keycloak_user.user_jane.id,
  }
}
output "wloadif_client_id" {
  description = "Workload Identity Federation Client ID"
  value       = keycloak_openid_client.google_wloadif_client.client_id
  sensitive = false
}
output "wloadif_client_scope" {
  description = "Workload Identity Federation Client Scope"
  value       = keycloak_openid_client_scope.google_wloadif_client_scope.name
  sensitive = false
}
output "wloadif_client_secret" {
  description = "Workload Identity Federation Client Secret"
  value       = keycloak_openid_client.google_wloadif_client.client_secret
  sensitive = true
}
output "wfif_client_id" {
  description = "Workforce Identity Federation Client ID"
  value       = keycloak_openid_client.google_wfif_client.client_id
  sensitive = false
}
output "wfif_client_scope" {
  description = "Workforce Identity Federation Client Scope"
  value       = keycloak_openid_client_scope.google_wfif_client_scope.name
  sensitive = false
}
output "wfif_client_secret" {
  description = "Workforce Identity Federation Client Secret"
  value       = keycloak_openid_client.google_wfif_client.client_secret
  sensitive = true
}
