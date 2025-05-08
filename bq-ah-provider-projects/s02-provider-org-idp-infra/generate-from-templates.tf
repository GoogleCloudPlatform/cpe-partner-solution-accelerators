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
  templates = {
    "environment.sh" = "environment.sh.tpl",
    "keycloak.yml" = "keycloak.yml.tpl",
  }
}

resource "random_password" "keycloak_admin_pw" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "local_file" "generated" {
  for_each = local.templates

  content  = templatefile("${path.module}/../templates/${each.value}",
    {
      project_id = data.google_project.project.project_id,
      generated_path = "${abspath(path.module)}/../generated",
      db_instance = "${google_sql_database_instance.keycloak.connection_name}",
      db_ip = "${google_sql_database_instance.keycloak.private_ip_address}",
      db_username = trimsuffix(google_service_account.keycloak_sa.email, ".gserviceaccount.com")
      keycloak_admin_pw = "${random_password.keycloak_admin_pw.result}",
      keycloak_google_sa = "${google_service_account.keycloak_sa.email}",
      keycloak_image_name = docker_registry_image.keycloak.name,
      dns_name = trimsuffix(var.dns_domain_name, "."),
      gateway_address_ip = google_compute_global_address.gateway.address,
      gateway_address_name = google_compute_global_address.gateway.name,
      gke_cluster_name = google_container_cluster.lab["cl-shared-apps"].name
      gke_cluster_location = google_container_cluster.lab["cl-shared-apps"].location
      keycloak_admin_password_secret_name = google_secret_manager_secret_version.keycloak_admin_password_version.name
    }
  )
  filename = "${path.module}/../generated/${each.key}"
  file_permission = 0644
}
