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

module "project-services-cust-seed" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.5.0"

  project_id                  = data.google_project.cust_seed_project.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

data "google_project" "cust_seed_project" {
  project_id = var.cust_project_id_seed
}
