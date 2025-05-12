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

# Override Domain restricted sharing - allow all in customer managed projects
resource "google_org_policy_policy" "override_drs_cx_folder" {
  parent = "${google_folder.prov-cx.name}"
  name   = "${google_folder.prov-cx.name}/policies/iam.allowedPolicyMemberDomains"

  spec {
    inherit_from_parent = false

    rules {
      allow_all  = "TRUE"
    }
  }
}
