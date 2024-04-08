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

variable "project_id_seed" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "project_id_bq_src_ds" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "project_id_bq_shared_ds" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "project_id_ah_exchg" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "project_id_nonvpcsc_ah_exchg" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "project_id_bq_and_ah" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "project_id_subscr_with_vpcsc" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "project_id_subscr_without_vpcsc" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "impersonate_sa_email" {
  description = "Google Cloud Service Account to impersonate"
  type        = string
}

variable "projects_activate_apis" {
  description = "Google Cloud Project ID"
  type        = list
  default     = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "aiplatform.googleapis.com",
    "dataflow.googleapis.com",
    "datastream.googleapis.com",
    "datacatalog.googleapis.com",
    "bigquery.googleapis.com",
    "analyticshub.googleapis.com",
    "composer.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "accesscontextmanager.googleapis.com",
  ]
}
variable "name_suffix" {
  description = "Suffix applied to resources created"
  type        = string
}

variable "location" {
  description = "BigQuery dataset and Analytics Hub exchange / listing location"
  type        = string
}
variable "region" {
  description = "Google Cloud Region"
  type        = string
}
variable "zone" {
  description = "Google Cloud Zone"
  type        = string
}
variable "allowlisted_external_ip_ranges" {
  description = "Allowlisted external range for GKE, SSH, etc"
  type        = list(string)
}
variable "tf_state_bucket" {
  description = "Terraform state bucket"
  type        = string
}

# primary region: 10.0.0.0 - 10.9.0.0
# secondary region: 10.10.0.0 - 10.19.0.0
variable "subnet_cidr" {
  description = "Subnet primary CIDR range"
  type        = string
  default     = "10.0.0.0/24"
}
variable "psa_ip" {
  description = "Private service access (PSA) CIDR range"
  type        = string
  default     = "10.100.0.0"
}
variable "subnet_cidr_sec" {
  description = "Subnet primary CIDR range"
  type        = string
  default     = "10.1.0.0/24"
}
variable "jumphost_ip" {
  description = "Jumphost internal IP"
  type        = string
  default     = "10.0.0.20"
}
variable "nat_bgp_asn" {
  description = "NAT BGP ASN"
  type        = string
  default     = "64514"
}
variable "pga_domains" {
  description = "Private Google Access domain overrides"
  type        = map
  default     =  {
    "googleapis"  = "googleapis.com."
    "gcr" = "gcr.io."
  }
}

variable "vpc_sc_dry_run" {
  description = "VPC SC dry-run mode"
  type        = bool
  default     = false
}
variable "vpc_sc_restricted_services" {
  description = "VPC SC restricted services"
  type        = list
  default     = []
}
variable "vpc_sc_global_access_policy_name" {
  description = "VPC SC global access policy name - publisher org"
  type        = string
  default     = "ahdemo-policy"
}
variable "vpc_sc_policy_parent_org_id" {
  description = "VPC SC policy parent organization id"
  type        = string
  default     = "431106855539"
}
variable "vpc_sc_access_level_corp_ip_subnetworks" {
  description = "VPC SC access level allowed external IPs"
  type        = list
  default     = []
}
variable "vpc_sc_access_level_corp_allowed_identities" {
  description = "VPC SC access level allowed identities"
  type        = list
  default     = []
}
variable "vpc_sc_allow_all_for_public_listing" {
  description = "VPC SC open perimiter to allow public listing for everyone"
  type        = bool
  default     = false
}
variable "vpc_sc_ah_subscriber_identities" {
  description = "VPC SC / AH allowed subscriber identities - format: list of 'user:<email>' or 'serviceAccount:<email>' items"
  type        = list
  default     = []
}
variable "vpc_sc_ah_subscriber_project_resources_with_numbers" {
  description = "VPC SC / AH allowed subscriber project numbers - format list of 'projects/project_number' items"
  type        = list
  default     = []
}
variable "vpc_sc_subscriber_global_access_policy_name" {
  description = "VPC SC global access policy name - subscriber org"
  type        = string
  default     = "ahdemo-subscriber-policy"
}
variable "vpc_sc_subscriber_project_org_id" {
  description = "VPC SC subscriber project's org id - format: 'organization id number'"
  type        = string
}
variable "vpc_sc_subscriber_access_level_corp_ip_subnetworks" {
  description = "VPC SC access level allowed external IPs"
  type        = list
}
variable "vpc_sc_subscriber_access_level_corp_allowed_identities" {
  description = "VPC SC access level allowed identities"
  type        = list
}

variable "ah_subscribers_iam_members" {
  description = "AH allowed subscriber identities"
  type        = list
  default     = []
}
variable "ah_subscription_viewers_iam_members" {
  description = "AH allowed subscription viewers (can request access, can't subscribe)"
  type        = list
  default     = []
}
variable "ah_listing_request_access_email_or_url" {
  description = "Contact for requesting access to the listing (e-mail address or URL). The request access button will redirect here."
  type        = string
}

variable "subscriber_projects_readers_iam_members" {
  description = "Subscriber project BQ readers who are NOT subscribers and have nothing on the publisher side"
  type        = list
  default     = []
}
variable "subscriber_sa_email" {
  description = "Subscriber Service Account e-mail"
  type        = string
}
variable "subscriber_sa_users" {
  description = "List of users who can impersonate the subscriber SA"
  type        = list
  default     = []
}
