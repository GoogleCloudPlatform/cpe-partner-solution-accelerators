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

module "publ-project-services-seed" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0.0"

  project_id                  = data.google_project.publ_seed_project.project_id
  activate_apis               = var.projects_activate_apis_seed
  disable_dependent_services  = false
  disable_services_on_destroy = false
}

module "publ-project-factory" {
  for_each = toset( [
    "${var.publ_project_id_bq_fed_ds}",
    "${var.publ_project_id_bq_src_ds}",
    "${var.publ_project_id_bq_shared_ds}",
    "${var.publ_project_id_ah_exchg}",
    "${var.publ_project_id_nonvpcsc_ah_exchg}",
    "${var.publ_project_id_bq_and_ah}",
    ] )
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 17.0.0"

  name                 = each.value
  random_project_id    = false
  folder_id            = google_folder.publ-root.id
  billing_account      = var.billing_account_id
  activate_apis        = var.projects_activate_apis_seed
  default_service_account     = "deprivilege"
  disable_dependent_services  = false
  disable_services_on_destroy = false
  deletion_policy = "DELETE"
}
