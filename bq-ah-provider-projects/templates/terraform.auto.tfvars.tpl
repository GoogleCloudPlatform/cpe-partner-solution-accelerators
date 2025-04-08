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

# BOTH
name_suffix = "{{SUFFIX}}"
location = "us"
region = "us-central1"
zone = "us-central1-a"
dns_zone_name = "{{DNS_ZONE_NAME}}"
dns_domain_name = "{{DNS_DOMAIN_NAME}}"
wlwfif_pool_name = "keycloak-oidc-pool-{{SUFFIX}}"
wlwfif_provider_name = "keycloak-oidc-provider-{{SUFFIX}}"

allowlisted_external_ip_ranges = [
    "212.51.151.0/24", # home
    "104.132.0.0/16", # office
    "104.135.0.0/16", # office
    "2a02:168:5231:0::/64", # home
    "2a00:79e0:48:700::/64", # office
    "2a00:79e0:9d:200::/64", # office
]

allowlisted_external_ip_ranges_v4only = [
    "212.51.151.0/24", # home
    "104.132.0.0/16", # office
    "104.135.0.0/16", # office
]

gcloud_user = "{{GCLOUD_USER}}"
billing_account_id = "{{BILLING_ACCOUNT_ID}}"
cx_billing_account_id = "{{CX_BILLING_ACCOUNT_ID}}"

# PROVIDER
prov_org_id = {{PROV_ORG_ID}} # {{PROV_ORG_NAME}}
prov_project_id_prefix = "{{PROV_PROJECT_ID_PREFIX}}"
prov_project_id_seed = "{{PROV_PROJECT_ID_SEED}}"
prov_project_id_idp = "{{PROV_PROJECT_ID_PREFIX}}-idp"
prov_project_id_bqds = "{{PROV_PROJECT_ID_PREFIX}}-bqds"
prov_tf_state_bucket = "{{PROV_STATE_BUCKET}}"
prov_admin_user = "{{PROV_ADMIN_USER}}"
prov_project_owners = [ "user:{{PROV_ADMIN_USER}}" ]

# UNUSED FOR NOW / LEGACY
prov_vpc_sc_dry_run = false
prov_vpc_sc_restricted_services = [ "cloudkms.googleapis.com" ]
prov_vpc_sc_policy_parent_org_id = {{PROV_ORG_ID}} # {{PROV_ORG_NAME}}
prov_vpc_sc_global_access_policy_name = "xocmek-provider-policy"
prov_vpc_sc_access_level_corp_ip_subnetworks = [
    "2a02:168:5231:0::/64", # home
    "212.51.151.0/24", # home
    "104.132.228.0/24", # office
    "2a00:79e0:48:700::/64", # office
    "2a00:79e0:9d:200::/64", # office
    ]
prov_vpc_sc_ah_customer_project_resources_with_numbers = []
prov_vpc_sc_access_level_corp_allowed_identities = [ 
    "user:{{GCLOUD_USER}}",
    "user:{{PROV_ADMIN_USER}}",
    ]
