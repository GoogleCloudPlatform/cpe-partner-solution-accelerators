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
  keycloak_users = distinct(flatten([
    for customer_name, customer in var.provider_managed_projects : [
      for user in toset( customer.provision_managed_identities ) : {
        key = "${customer_name}-${user.user_name}"
        customer_name = customer_name
        user = user
      }
    ]
  ]))
}

resource "random_password" "cx_managed_pw" {
  for_each         =  {
    for keycloak_user in local.keycloak_users : "${keycloak_user.customer_name}-${keycloak_user.user.user_name}" => keycloak_user
  }

  length           = 16
  special          = false
}

resource "keycloak_user" "cx_managed" {
  for_each         =  {
    for keycloak_user in local.keycloak_users : "${keycloak_user.customer_name}-${keycloak_user.user.user_name}" => keycloak_user
  }
  realm_id   = keycloak_realm.realm.id
  username   = "${each.value.customer_name}-${each.value.user.user_name}"
  enabled    = true

  email      = each.value.user.email
  first_name = each.value.user.first_name
  last_name  = each.value.user.last_name

  initial_password {
    value     = random_password.cx_managed_pw[each.key].result
    temporary = false
  }
}

resource "local_file" "test_users_password" {
  for_each = local.templates

  content  = <<EOT
%{ for keycloak_user in local.keycloak_users ~}
${keycloak_user.key}=${random_password.cx_managed_pw[keycloak_user.key].result}
%{ endfor ~}
EOT
  filename = "${path.module}/../generated/test_users_password.txt"
  file_permission = 0600
}
