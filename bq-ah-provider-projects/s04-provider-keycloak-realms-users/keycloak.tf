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

resource "keycloak_realm" "realm" {
  realm             = "google"
  enabled           = true
  display_name      = "Google Cloud Test Realm"
  display_name_html = "<b>Google Cloud Test Realm</b>"

  login_theme = "keycloak"

  access_code_lifespan = "1h"

  ssl_required    = "external"
  password_policy = "upperCase(1) and length(8) and forceExpiredPasswordChange(365) and notUsername"

  security_defenses {
    headers {
      x_frame_options                     = "SAMEORIGIN"
      content_security_policy             = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
    }
    brute_force_detection {
      permanent_lockout                 = false
      max_login_failures                = 30
      wait_increment_seconds            = 60
      quick_login_check_milli_seconds   = 1000
      minimum_quick_login_wait_seconds  = 60
      max_failure_wait_seconds          = 900
      failure_reset_time_seconds        = 43200
    }
  }
}

resource "keycloak_openid_client" "google_wloadif_client" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "google-wloadif-client"
  full_scope_allowed  = false # needed to remove account from aud claim, as aud claim being an array does not work with google identity federation

  name                = "google-wloadif-client"
  enabled             = true

  access_type         = "CONFIDENTIAL"
  valid_redirect_uris = [
    "http://localhost:8080/openid-callback",
  ]

  login_theme = "keycloak"
  implicit_flow_enabled = true
  standard_flow_enabled = true
  direct_access_grants_enabled = true
  service_accounts_enabled = true
}

resource "keycloak_openid_client_scope" "google_wloadif_client_scope" {
  realm_id = keycloak_realm.realm.id
  name     = "google-wloadif-client-scope"
  description = "Google Workload Identity Federation Client Scope for Audience"
}

resource "keycloak_openid_audience_protocol_mapper" "google_wloadif_audience_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.google_wloadif_client_scope.id
  name            = "google-wloadif-client-scope-audience-mapper"

  included_custom_audience = "//iam.googleapis.com/projects/${data.terraform_remote_state.provider-org-create-projects-bootstrap.outputs.project_number_idp}/locations/global/workloadIdentityPools/${var.wlwfif_pool_name}/providers/${var.wlwfif_provider_name}"
}

resource "keycloak_openid_client_default_scopes" "google_wloadif_client_default_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.google_wloadif_client.id

  default_scopes = [
    "acr",
    "email",
    "profile",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.google_wloadif_client_scope.name,
  ]
}

resource "keycloak_openid_client" "google_wfif_client" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "google-wfif-client"
  full_scope_allowed  = false # needed to remove account from aud claim, as aud claim being an array does not work with google identity federation

  name                = "google-wfif-client"
  enabled             = true

  access_type         = "CONFIDENTIAL"
  valid_redirect_uris = [
    "http://localhost:8080/openid-callback",
    "https://auth.cloud.google/signin-callback/locations/global/workforcePools/${var.wlwfif_pool_name}/providers/${var.wlwfif_provider_name}"
  ]

  login_theme = "keycloak"
  implicit_flow_enabled = true
  standard_flow_enabled = true
  direct_access_grants_enabled = true
  service_accounts_enabled = true
}

resource "keycloak_openid_client_scope" "google_wfif_client_scope" {
  realm_id = keycloak_realm.realm.id
  name     = "google-wfif-client-scope"
  description = "Google Workforce Identity Federation Client Scope for Audience"
}

resource "keycloak_openid_client_default_scopes" "google_wfif_client_default_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.google_wfif_client.id

  default_scopes = [
    "acr",
    "email",
    "profile",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.google_wfif_client_scope.name,
  ]
}

resource "random_password" "test_user_pw" {
  length           = 16
  special          = false
}

resource "keycloak_group" "common_group" {
  realm_id = keycloak_realm.realm.id
  name     = "common-group"
}

resource "keycloak_group" "foo_group" {
  realm_id = keycloak_realm.realm.id
  name     = "foo-group"
}

resource "keycloak_group" "bar_group" {
  realm_id = keycloak_realm.realm.id
  name     = "bar-group"
}

resource "keycloak_group_memberships" "common_group_members" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.common_group.id

  members  = [
    keycloak_user.user_john.username,
    keycloak_user.user_jane.username
  ]
}

resource "keycloak_group_memberships" "foo_group_members" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.foo_group.id

  members  = [
    keycloak_user.user_john.username,
  ]
}

resource "keycloak_group_memberships" "bar_group_members" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.bar_group.id

  members  = [
    keycloak_user.user_jane.username
  ]
}

resource "keycloak_user" "user_john" {
  realm_id   = keycloak_realm.realm.id
  username   = "john"
  enabled    = true

  email      = "john@domain.com"
  first_name = "John"
  last_name  = "Doe"

  initial_password {
    value     = random_password.test_user_pw.result
    temporary = false
  }
}

resource "keycloak_user" "user_jane" {
  realm_id   = keycloak_realm.realm.id
  username   = "jane"
  enabled    = true

  email      = "jane@domain.com"
  first_name = "Jane"
  last_name  = "Doe"

  initial_password {
    value     = random_password.test_user_pw.result
    temporary = false
  }
}
