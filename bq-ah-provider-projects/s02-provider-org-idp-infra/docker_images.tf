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
  repo_host = "${google_artifact_registry_repository.my-repo.location}-docker.pkg.dev"
  repo_tag = "${local.repo_host}/${google_artifact_registry_repository.my-repo.project}/${google_artifact_registry_repository.my-repo.name}"
  keycloak_sha1 = sha1(join("", [for f in fileset("${path.module}/../src/keycloak", "*") : filesha1("${path.module}/../src/keycloak/${f}")]))
  keycloak_sha1_prefix = substr(local.keycloak_sha1, 0, 8)
}

resource "docker_image" "keycloak" {
  name = "${local.repo_tag}/keycloak:${local.keycloak_sha1_prefix}"
  build {
    context = "../src/keycloak"
    tag = [ "${local.repo_tag}/keycloak:${local.keycloak_sha1_prefix}" ]
    no_cache = true
  }
  triggers = {
    dir_sha1 = local.keycloak_sha1
  }
}

resource "docker_registry_image" "keycloak" {
  name          = docker_image.keycloak.name
  keep_remotely = true
}
