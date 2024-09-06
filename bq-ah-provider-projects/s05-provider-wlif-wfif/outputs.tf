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

output "wloadif_iam_principal" {
  description = "Workload Identity Federation Client ID"
  value       = "principal://iam.googleapis.com/projects/${local.project_number_idp}/locations/global/workloadIdentityPools/${var.wlwfif_pool_name}/subject/"
  sensitive = false
}
output "wfif_iam_principal" {
  description = "Workforce Identity Federation Client ID"
  value       = "principal://iam.googleapis.com/locations/global/workforcePools/${var.wlwfif_pool_name}/subject/"
  sensitive = false
}
