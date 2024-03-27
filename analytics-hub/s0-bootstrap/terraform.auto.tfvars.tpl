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

# Projects need to be created using a different process due to internal policies
project_id_seed = "ahdemo-{{SUFFIX}}-seed"
project_id_bq_src_ds = "ahdemo-{{SUFFIX}}-bq-src-ds"
project_id_bq_shared_ds = "ahdemo-{{SUFFIX}}-bq-shared-ds"
project_id_ah_exchg = "ahdemo-{{SUFFIX}}-ah-exchg"
project_id_nonvpcsc_ah_exchg = "ahdemo-{{SUFFIX}}-nonvpcsc-ah-exch"
project_id_bq_and_ah = "ahdemo-{{SUFFIX}}-bq-ah-sameproj"
project_id_subscr_with_vpcsc = "ahdemo-{{SUFFIX}}-subscr-vpcsc"
project_id_subscr_without_vpcsc = "ahdemo-{{SUFFIX}}-subscr"
impersonate_sa_email = "{{TERRAFORM_SA_EMAIL}}"

name_suffix = "{{SUFFIX}}"
location = "us"
region = "us-central1"
zone = "us-central1-a"
tf_state_bucket = "{{STATE_BUCKET}}"

allowlisted_external_ip_ranges = ["104.132.0.0/16", "81.6.39.0/24", "178.197.217.0/24", "212.51.0.0/16" ]

vpc_sc_dry_run = false
vpc_sc_restricted_services = [ "analyticshub.googleapis.com","bigquery.googleapis.com" ]
vpc_sc_policy_parent_org_id = {{PUBLISHER_ORG_ID}} # {{PUBLISHER_ORG_NAME}}
vpc_sc_global_access_policy_name = "ahdemo-policy"
vpc_sc_access_level_corp_ip_subnetworks = [ 
    "2a02:168:5231:0::/64", # home
    "212.51.151.0/24", # home
    "104.132.228.0/24", # office
    "2a00:79e0:48:700::/64", # office
    ]
vpc_sc_access_level_corp_allowed_identities = [ 
    "user:{{ADMIN_USER}}",
    "serviceAccount:{{TERRAFORM_SA_EMAIL}}",
    ]
vpc_sc_allow_all_for_public_listing = false

vpc_sc_ah_subscriber_identities = [ "user:{{SUBSCRIBER_USER}}", "serviceAccount:{{SUBSCRIBER_SA_EMAIL}}" ]
vpc_sc_ah_subscriber_project_resources_with_numbers = []

vpc_sc_subscriber_project_org_id = {{SUBSCRIBER_ORG_ID}} # {{SUBSCRIBER_ORG_NAME}}
vpc_sc_subscriber_global_access_policy_name = "ahdemo-subscriber-policy"
vpc_sc_subscriber_access_level_corp_ip_subnetworks = [ 
    "2a02:168:5231:0::/64", # home
    "212.51.151.0/24", # home
    "104.132.228.0/24", # office
    "2a00:79e0:48:700::/64", # office
    ]
vpc_sc_subscriber_access_level_corp_allowed_identities = [ "user:{{ADMIN_USER}}" ]

ah_subscribers_iam_members = [ 
    "user:{{SUBSCRIBER_USER}}", 
    "serviceAccount:{{SUBSCRIBER_SA_EMAIL}}" 
    ]
subscriber_projects_readers_iam_members = [ "user:{{BQREADER_USER}}" ]
subscriber_sa_email = "{{SUBSCRIBER_SA_EMAIL}}"
subscriber_sa_users = [
    "user:{{TERRAFORM_SA_USER}}", 
    "user:{{ADMIN_USER}}", 
    "user:{{SUBSCRIBER_USER}}", 
    ]
