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

data "google_project" "prov_seed_project" {
  project_id = var.prov_project_id_seed
}

resource "google_project" "cx_projects" {
  for_each = var.provider_managed_projects

  project_id           = "bqprovpr-0819c0-cx-${each.key}"
  name                 = "bqprovpr-0819c0-cx-${each.key}"
  folder_id            = data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.folder_id_cx
  billing_account      = var.cx_billing_account_id
  deletion_policy      = "DELETE"

  labels = {
    customer_name = each.key
  }

}

module "project-services-cx" {
  for_each = var.provider_managed_projects

  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.1"

  project_id                  = "bqprovpr-0819c0-cx-${each.key}"
  activate_apis               = var.projects_activate_apis_cx
  disable_services_on_destroy = false
}

locals {
  wloadif_iam_principal = data.terraform_remote_state.provider-wlif-wfif.outputs.wloadif_iam_principal
  wfif_iam_principal = data.terraform_remote_state.provider-wlif-wfif.outputs.wfif_iam_principal
  keycloak_users = data.terraform_remote_state.keycloak.outputs.managed_users
  bqds_exchange_id = data.terraform_remote_state.provider-bq-ds-data-sharing.outputs.bqds_exchange_data_exchange_id
  dns_name_trimmed = trimsuffix(var.dns_domain_name, ".")
}
