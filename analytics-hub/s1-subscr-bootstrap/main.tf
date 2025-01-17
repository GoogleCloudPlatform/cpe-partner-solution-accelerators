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

module "project-services-subscr-seed" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0.0"

  project_id                  = data.google_project.subscr_seed_project.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

module "project-services-subscr-with-vpcsc" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0.0"

  project_id                  = data.google_project.subscr_subscr_with_vpcsc.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

module "project-services-subscr-without-vpcsc" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 17.0.0"

  project_id                  = data.google_project.subscr_subscr_without_vpcsc.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

data "google_project" "subscr_seed_project" {
  project_id = var.subscr_project_id_seed
}

data "google_project" "subscr_subscr_with_vpcsc" {
  project_id = var.subscr_project_id_subscr_with_vpcsc
}

data "google_project" "subscr_subscr_without_vpcsc" {
  project_id = var.subscr_project_id_subscr_without_vpcsc
}

data "google_project" "subscr_subscr_xpn" {
  project_id = var.subscr_project_id_subscr_xpn
}

data "google_project" "subscr_subscr_vm" {
  project_id = var.subscr_project_id_subscr_vm
}
