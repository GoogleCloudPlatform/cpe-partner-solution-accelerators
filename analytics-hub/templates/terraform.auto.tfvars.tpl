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
location = "us-central1"
region = "us-central1"
zone = "us-central1-a"
allowlisted_external_ip4_ranges = [ {{ALLOWLISTED_IPV4_S}} ]
allowlisted_external_ip6_ranges = [ {{ALLOWLISTED_IPV6_S}} ]
vpc_sc_dry_run = false
vpc_sc_restricted_services = [ "analyticshub.googleapis.com","bigquery.googleapis.com","bigquery.googleapis.com","bigquerydatapolicy.googleapis.com","datacatalog.googleapis.com" ]
gcloud_user = "{{GCLOUD_USER}}"
billing_account_id = "{{BILLING_ACCOUNT_ID}}"

# PUBLISHER
# Projects need to be created using a different process due to internal policies
publ_project_id_prefix = "{{PUBL_PROJECT_ID_PREFIX}}"
publ_project_id_seed = "{{PUBL_PROJECT_ID_SEED}}"
publ_project_id_bq_fed_ds = "{{PUBL_PROJECT_ID_BQ_FED_DS}}"
publ_project_id_bq_src_ds = "{{PUBL_PROJECT_ID_BQ_SRC_DS}}"
publ_project_id_bq_shared_ds = "{{PUBL_PROJECT_ID_BQ_SHARED_DS}}"
publ_project_id_ah_exchg = "{{PUBL_PROJECT_ID_AH_EXCHG}}"
publ_project_id_nonvpcsc_ah_exchg = "{{PUBL_PROJECT_ID_NONVPCSC_AH_EXCHG}}"
publ_project_id_bq_and_ah = "{{PUBL_PROJECT_ID_BQ_AND_AH}}"
publ_impersonate_sa_email = "{{PUBL_TERRAFORM_SA_EMAIL}}"
publ_tf_state_bucket = "{{PUBL_STATE_BUCKET}}"
publ_ah_listing_request_access_email_or_url = "{{REQUEST_ACCESS_EMAIL_OR_URL}}"
publ_terraform_sa_name = "{{PUBL_TERRAFORM_SA_NAME}}"
publ_terraform_sa_email = "{{PUBL_TERRAFORM_SA_EMAIL}}"
publ_terraform_sa_users_iam_members = [ "user:{{PUBL_TERRAFORM_SA_USER}}" ]
publ_admin_user = "{{PUBL_ADMIN_USER}}"
publ_project_owners = [ "user:{{PUBL_ADMIN_USER}}" ]
publ_drs_allowlisted_org_ids = [ {{PUBL_DRS_ALLOWLISTED_ORG_IDS_S}} ]

publ_enable_policy_tags = {{PUBL_ENABLE_POLICY_TAGS}}
publ_allowlisted_vpcsc_opt = {{PUBL_ALLOWLISTED_VPCSC_OPT}}

publ_vpc_sc_policy_parent_org_id = {{PUBLISHER_ORG_ID}} # {{PUBLISHER_ORG_NAME}}
publ_vpc_sc_global_access_policy_name = "ahdemo-publisher-policy"
publ_vpc_sc_access_level_corp_ip_subnetworks = [ {{ALLOWLISTED_IPV4_S}},{{ALLOWLISTED_IPV6_S}} ]
publ_vpc_sc_ah_subscriber_project_resources_with_numbers = []
publ_vpc_sc_access_level_corp_allowed_identities = [ 
    "user:{{GCLOUD_USER}}",
    "user:{{PUBL_ADMIN_USER}}",
    "serviceAccount:{{PUBL_TERRAFORM_SA_EMAIL}}",
    ]
publ_vpc_sc_allow_all_for_public_listing = false
publ_vpc_sc_ah_subscriber_identities = [ 
    "user:{{SUBSCRIBER_USER}}",
    "user:{{SUBSCR_ADMIN_USER}}",
    "serviceAccount:{{SUBSCR_SUBSCRIBER_SA_EMAIL}}",
    "serviceAccount:{{SUBSCR_TERRAFORM_SA_EMAIL}}"
    ]
publ_ah_subscribers_iam_members = [
    "user:{{SUBSCRIBER_USER}}",
    "serviceAccount:{{SUBSCR_SUBSCRIBER_SA_EMAIL}}",
    "serviceAccount:{{SUBSCR_TERRAFORM_SA_EMAIL}}"
    ]
publ_ah_subscription_viewers_iam_members = [
    "user:{{SUBSCRIPTION_VIEWER_USER}}",
    ]

# SUBSCRIBER
# Projects need to be created using a different process due to internal policies
subscr_project_id_prefix = "{{SUBSCR_PROJECT_ID_PREFIX}}"
subscr_project_id_seed = "{{SUBSCR_PROJECT_ID_SEED}}"
subscr_project_id_subscr_with_vpcsc = "{{SUBSCR_PROJECT_ID_WITH_VPCSC}}"
subscr_project_id_subscr_without_vpcsc = "{{SUBSCR_PROJECT_ID_WITHOUT_VPCSC}}"
subscr_project_id_subscr_xpn = "{{SUBSCR_PROJECT_ID_PREFIX}}-xpn"
subscr_project_id_subscr_vm = "{{SUBSCR_PROJECT_ID_PREFIX}}-vm"
subscr_impersonate_sa_email = "{{SUBSCR_TERRAFORM_SA_EMAIL}}"
subscr_tf_state_bucket = "{{SUBSCR_STATE_BUCKET}}"
subscr_terraform_sa_name = "{{SUBSCR_TERRAFORM_SA_NAME}}"
subscr_terraform_sa_email = "{{SUBSCR_TERRAFORM_SA_EMAIL}}"
subscr_terraform_sa_users_iam_members = [ "user:{{SUBSCR_TERRAFORM_SA_USER}}" ]
subscr_admin_user = "{{SUBSCR_ADMIN_USER}}"
subscr_project_owners = [ "user:{{SUBSCR_ADMIN_USER}}" ]
subscr_drs_allowlisted_org_ids = [ {{SUBSCR_DRS_ALLOWLISTED_ORG_IDS_S}} ]

subscr_vpc_sc_policy_parent_org_id = {{SUBSCRIBER_ORG_ID}} # {{SUBSCRIBER_ORG_NAME}}
subscr_vpc_sc_global_access_policy_name = "ahdemo-subscriber-policy"
subscr_vpc_sc_access_level_corp_ip_subnetworks = [ {{ALLOWLISTED_IPV4_S}},{{ALLOWLISTED_IPV6_S}} ]
subscr_vpc_sc_access_level_corp_allowed_identities = [
    "user:{{GCLOUD_USER}}",
    "user:{{SUBSCR_ADMIN_USER}}",
    "user:{{SUBSCRIBER_USER}}",
    "user:{{BQREADER_USER}}",
    "serviceAccount:{{SUBSCR_TERRAFORM_SA_EMAIL}}",
    "serviceAccount:{{SUBSCR_SUBSCRIBER_SA_EMAIL}}",
    ]
subscr_subscriber_projects_ah_subscribers_iam_members = [
    "user:{{SUBSCRIBER_USER}}",
    "serviceAccount:{{SUBSCR_SUBSCRIBER_SA_EMAIL}}"
    ]
subscr_subscriber_projects_ah_subscription_viewer_iam_members = [
    "user:{{SUBSCRIPTION_VIEWER_USER}}",
    ]
subscr_subscriber_projects_bq_readers_iam_members = [ 
    "user:{{BQREADER_USER}}"
    ]
subscr_subscriber_sa_name = "{{SUBSCR_SUBSCRIBER_SA_NAME}}"
subscr_subscriber_sa_email = "{{SUBSCR_SUBSCRIBER_SA_EMAIL}}"
subscr_subscriber_sa_users_iam_members = [
    "user:{{GCLOUD_USER}}",
    "user:{{SUBSCR_ADMIN_USER}}",
    "user:{{SUBSCRIBER_USER}}",
    ]
