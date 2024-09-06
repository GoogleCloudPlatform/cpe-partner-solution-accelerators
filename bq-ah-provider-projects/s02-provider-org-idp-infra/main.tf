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

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.1"

  project_id                  = data.google_project.project.project_id

  activate_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "aiplatform.googleapis.com",
    "dataflow.googleapis.com",
    "datastream.googleapis.com",
    "datacatalog.googleapis.com",
    "bigquery.googleapis.com",
    "analyticshub.googleapis.com",
    "composer.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "trafficdirector.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "gkehub.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
}
