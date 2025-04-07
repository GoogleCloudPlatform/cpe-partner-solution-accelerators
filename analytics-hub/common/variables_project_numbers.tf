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

variable "subscr_root_folder_id" {
  description = "Google Cloud Folder ID"
  type        = string
}
variable "subscr_project_number_seed" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "subscr_project_number_subscr_with_vpcsc" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "subscr_project_number_subscr_without_vpcsc" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "subscr_project_number_subscr_xpn" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "subscr_project_number_subscr_vm" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "publ_root_folder_id" {
  description = "Google Cloud Folder ID"
  type        = string
}
variable "publ_project_number_seed" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "publ_project_number_bq_src_ds" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "publ_project_number_bq_shared_ds" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "publ_project_number_ah_exchg" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "publ_project_number_nonvpcsc_ah_exchg" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "publ_project_number_bq_and_ah" {
  description = "Google Cloud Project ID"
  type        = string
}
