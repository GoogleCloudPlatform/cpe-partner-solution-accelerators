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
variable "projects_activate_apis" {
  description = "Google Cloud Project ID"
  type        = list
  default     = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "orgpolicy.googleapis.com",
    "cloudkms.googleapis.com",
  ]
}
variable "org_admins_wide_iam_roles" {
  description = "IAM roles to grant on the Cloud Organization for admins"
  type        = list
  default     = [
    "roles/owner",
    "roles/resourcemanager.projectIamAdmin",
    "roles/browser",
    "roles/accesscontextmanager.policyAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.organizationAdmin",
    "roles/resourcemanager.tagAdmin",
    "roles/orgpolicy.policyAdmin",
    "roles/bigquery.admin",
    "roles/logging.privateLogViewer",
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
variable "gcloud_user" {
  description = "Active user in gcloud auth list - usually org admin in both orgs"
  type        = string
}
variable "billing_account_id" {
  description = "Billing Account ID"
  type        = string
}

# PROVIDER
variable "prov_project_id_seed" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "prov_tf_state_bucket" {
  description = "Terraform state bucket"
  type        = string
}
variable "prov_admin_user" {
  description = "Publisher admin user - will get wide org-wide privileges"
  type        = string
}
variable "prov_project_owners" {
  description = "Additional IAM members to add to the publisher projects"
  type        = list
}

variable "prov_vpc_sc_policy_parent_org_id" {
  description = "VPC SC policy parent organization id"
  type        = string
}
variable "prov_vpc_sc_global_access_policy_name" {
  description = "VPC SC global access policy name - publisher org"
  type        = string
}
variable "prov_vpc_sc_access_level_corp_ip_subnetworks" {
  description = "VPC SC access level allowed external IPs"
  type        = list
  default     = []
}
variable "prov_vpc_sc_ah_customer_project_resources_with_numbers" {
  description = "VPC SC / AH allowed subscriber project numbers - format list of 'projects/project_number' items"
  type        = list
  default     = []
}
variable "prov_vpc_sc_access_level_corp_allowed_identities" {
  description = "VPC SC access level allowed identities"
  type        = list
  default     = []
}
variable "prov_vpc_sc_ah_customer_identities" {
  description = "VPC SC / AH allowed subscriber identities - format: list of 'user:<email>' or 'serviceAccount:<email>' items"
  type        = list
  default     = []
}

# CUSTOMER
variable "cust_project_id_seed" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "cust_tf_state_bucket" {
  description = "Terraform state bucket"
  type        = string
}
variable "cust_admin_user" {
  description = "Subscriber admin user - will get wide org-wide privileges"
  type        = string
}
variable "cust_project_owners" {
  description = "Additional IAM members to add to the subscriber projects"
  type        = list
}

variable "cust_cmek_keyring_name" {
  description = "CMEK keyring name"
  type        = string
}
variable "cust_cmek_key_name" {
  description = "CMEK key name"
  type        = string
}

variable "cust_vpc_sc_policy_parent_org_id" {
  description = "VPC SC subscriber project's org id - format: 'organization id number'"
  type        = string
}
variable "cust_vpc_sc_global_access_policy_name" {
  description = "VPC SC global access policy name - subscriber org"
  type        = string
  default     = "ahdemo-subscriber-policy"
}
variable "cust_vpc_sc_access_level_corp_ip_subnetworks" {
  description = "VPC SC access level allowed external IPs"
  type        = list
}
variable "cust_vpc_sc_access_level_corp_allowed_identities" {
  description = "VPC SC access level allowed identities"
  type        = list
}
variable "cust_subscriber_projects_ah_subscribers_iam_members" {
  description = "Subscriber project AH subscribers"
  type        = list
  default     = []
}
