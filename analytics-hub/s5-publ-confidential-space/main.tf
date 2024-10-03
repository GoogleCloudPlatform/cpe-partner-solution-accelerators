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

data "google_project" "publ_seed_project" {
  project_id = var.publ_project_id_seed
}

resource "google_project" "publ_cs_cx_foo_project" {
  name                 = "${var.publ_project_id_prefix}-cs-cx-foo"
  project_id           = "${var.publ_project_id_prefix}-cs-cx-foo"
  folder_id            = "folders/${var.publ_root_folder_id}"
  billing_account      = var.billing_account_id
}

resource "google_project_service" "publ_cs_cx_foo_project" {
  for_each = toset(var.projects_activate_apis)

  project = google_project.publ_cs_cx_foo_project.name
  service = each.value
  disable_on_destroy = false
}
