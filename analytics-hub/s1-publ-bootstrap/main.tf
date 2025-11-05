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

module "project-services-publ-seed" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2.0"

  project_id                  = data.google_project.publ_seed_project.project_id
  activate_apis               = concat(var.projects_activate_apis_seed, ["compute.googleapis.com"])
  disable_services_on_destroy = false
}

module "project-services-publ-bq-src-ds" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2.0"

  project_id                  = data.google_project.publ_bq_src_ds.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

module "project-services-publ-bq-fed-ds" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2.0"

  project_id                  = data.google_project.publ_bq_fed_ds.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

module "project-services-publ-bq-shared-ds" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2.0"

  project_id                  = data.google_project.publ_bq_shared_ds.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

module "project-services-publ-vpcsc-ah-exchg" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2.0"

  project_id                  = data.google_project.publ_ah_exchg.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

module "project-services-publ-nonvpcsc-ah-exchg" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2.0"

  project_id                  = data.google_project.publ_nonvpcsc_ah_exchg.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

module "project-services-publ-bq-and-ah" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2.0"

  project_id                  = data.google_project.publ_bq_and_ah.project_id
  activate_apis               = var.projects_activate_apis
  disable_services_on_destroy = false
}

data "google_project" "publ_seed_project" {
  project_id = var.publ_project_id_seed
}

data "google_project" "publ_bq_fed_ds" {
  project_id = var.publ_project_id_bq_fed_ds
}

data "google_project" "publ_bq_src_ds" {
  project_id = var.publ_project_id_bq_src_ds
}

data "google_project" "publ_bq_shared_ds" {
  project_id = var.publ_project_id_bq_shared_ds
}

data "google_project" "publ_ah_exchg" {
  project_id = var.publ_project_id_ah_exchg
}

data "google_project" "publ_nonvpcsc_ah_exchg" {
  project_id = var.publ_project_id_nonvpcsc_ah_exchg
}

data "google_project" "publ_bq_and_ah" {
  project_id = var.publ_project_id_bq_and_ah
}
