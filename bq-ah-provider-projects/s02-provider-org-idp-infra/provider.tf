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
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
      version = "5.41.0"
    }
    google = {
      source = "hashicorp/google"
      version = "5.41.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address     = "${var.region}-docker.pkg.dev"
    config_file = pathexpand("~/.docker/config.json")
  }
}

data "google_project" "project" {
  project_id = var.prov_project_id_idp
}

provider "google-beta" {
  project     = var.prov_project_id_idp
  region      = var.region
  zone        = var.zone
}

provider "google" {
  project     = var.prov_project_id_idp
  region      = var.region
  zone        = var.zone
}