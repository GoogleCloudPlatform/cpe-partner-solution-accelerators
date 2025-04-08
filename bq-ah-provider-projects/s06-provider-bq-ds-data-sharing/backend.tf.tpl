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

terraform {
  backend "gcs" {
    bucket = "{{PROV_STATE_BUCKET}}"
    prefix = "terraform/provider-bq-ds-data-sharing/state"
  }
}

data "terraform_remote_state" "keycloak" {
  backend = "gcs"

  config = {
    bucket = "{{PROV_STATE_BUCKET}}"
    prefix = "terraform/provider-keycloak-realms/state"
  }
}

data "terraform_remote_state" "provider-org-idp-infra" {
  backend = "gcs"

  config = {
    bucket = "{{PROV_STATE_BUCKET}}"
    prefix = "terraform/provider-org-idp-infra/state"
  }
}

data "terraform_remote_state" "provider-org-create-projects-bootstrap" {
  backend = "gcs"

  config = {
    bucket = "{{PROV_STATE_BUCKET}}"
    prefix = "terraform/provider-org-create-projects-bootstrap/state"
  }
}
