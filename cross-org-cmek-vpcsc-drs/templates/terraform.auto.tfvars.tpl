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
allowlisted_external_ip_ranges = ["104.132.0.0/16", "81.6.39.0/24", "178.197.217.0/24", "212.51.0.0/16" ]
vpc_sc_dry_run = false
vpc_sc_restricted_services = [ "cloudkms.googleapis.com" ]
gcloud_user = "{{GCLOUD_USER}}"
billing_account_id = "{{BILLING_ACCOUNT_ID}}"

# PROVIDER
prov_project_id_seed = "{{PROV_PROJECT_ID_SEED}}"
prov_tf_state_bucket = "{{PROV_STATE_BUCKET}}"
prov_admin_user = "{{PROV_ADMIN_USER}}"
prov_project_owners = [ "user:{{PROV_ADMIN_USER}}" ]

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

# CUSTOMER
cust_project_id_seed = "{{CUST_PROJECT_ID_SEED}}"
cust_tf_state_bucket = "{{CUST_STATE_BUCKET}}"
cust_admin_user = "{{CUST_ADMIN_USER}}"
cust_project_owners = [ "user:{{CUST_ADMIN_USER}}" ]

cust_cmek_keyring_name = "xocmek_{{SUFFIX}}_keyring"
cust_cmek_key_name = "xocmek_{{SUFFIX}}_key"

cust_vpc_sc_policy_parent_org_id = {{CUST_ORG_ID}} # {{CUST_ORG_NAME}}
cust_vpc_sc_global_access_policy_name = "xocmek-customer-policy"
cust_vpc_sc_access_level_corp_ip_subnetworks = [
    "2a02:168:5231:0::/64", # home
    "212.51.151.0/24", # home
    "104.132.228.0/24", # office
    "2a00:79e0:48:700::/64", # office
    "2a00:79e0:9d:200::/64", # office
    ]
cust_vpc_sc_access_level_corp_allowed_identities = [
    "user:{{GCLOUD_USER}}",
    "user:{{CUST_ADMIN_USER}}",
    ]
