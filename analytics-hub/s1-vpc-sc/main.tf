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
  vpc_sc_ah_subscriber_project_resources_with_numbers = tolist(concat(var.vpc_sc_ah_subscriber_project_resources_with_numbers, ["projects/${data.google_project.subscr_with_vpcsc.number}","projects/${data.google_project.subscr_without_vpcsc.number}"]))
  #vpc_sc_ah_subscriber_project_resources_with_numbers = var.vpc_sc_ah_subscriber_project_resources_with_numbers
}

data "google_project" "seed_project" {
  project_id = var.project_id_seed
}

data "google_project" "bq_src_ds" {
  project_id = var.project_id_bq_src_ds
}

data "google_project" "bq_shared_ds" {
  project_id = var.project_id_bq_shared_ds
}

data "google_project" "ah_exchg" {
  project_id = var.project_id_ah_exchg
}

data "google_project" "nonvpcsc_ah_exchg" {
  project_id = var.project_id_nonvpcsc_ah_exchg
}

data "google_project" "bq_and_ah" {
  project_id = var.project_id_bq_and_ah
}

data "google_project" "subscr_with_vpcsc" {
  project_id = var.project_id_subscr_with_vpcsc
}

data "google_project" "subscr_without_vpcsc" {
  project_id = var.project_id_subscr_without_vpcsc
}
