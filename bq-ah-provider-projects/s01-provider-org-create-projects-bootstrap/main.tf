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

module "project-services-prov-seed" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 16.0"

  project_id                  = data.google_project.prov_seed_project.project_id
  activate_apis               = var.projects_activate_apis_seed
  disable_services_on_destroy = false
}

data "google_project" "prov_seed_project" {
  project_id = var.prov_project_id_seed
}

module "publ-project-factory" {
  for_each = toset( [
    "${var.prov_project_id_idp}",
    ] )
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 16.0"

  name                 = each.value
  random_project_id    = false
  folder_id            = google_folder.prov-core.id
  billing_account      = var.billing_account_id
  activate_apis        = var.projects_activate_apis
  default_service_account     = "deprivilege"
  disable_dependent_services  = false
  disable_services_on_destroy = false
}