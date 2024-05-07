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

data "google_storage_bucket" "publ_tf_state" {
  name = var.publ_tf_state_bucket
}
