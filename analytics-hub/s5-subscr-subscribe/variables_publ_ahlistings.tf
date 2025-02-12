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

variable "ah_project_id" {
  description = "Google Cloud Analytics Hub Project Id"
  type        = string
}
variable "ah_project_number" {
  description = "Google Cloud Analytics Hub Project Number"
  type        = string
}
variable "ah_exchange_id" {
  description = "Google Cloud Analytics Hub Exchange Id"
  type        = string
}
variable "ah_listing_id" {
  description = "Google Cloud Analytics Hub Listing Id"
  type        = string
}
variable "ah_exchange_name" {
  description = "Google Cloud Analytics Hub Exchange Name"
  type        = string
}
variable "ah_listing_name" {
  description = "Google Cloud Analytics Hub Listing Name"
  type        = string
}
variable "ah_location" {
  description = "Google Cloud BigQuery Linked Dataset location"
  type        = string
}
