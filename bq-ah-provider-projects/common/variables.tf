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
variable "gke_subnet_cidr" {
  description = "Subnet primary CIDR range"
  type        = string
  default     = "10.10.0.0/16"
}
variable "gke_clusters" {
  description = "GKE clusters to create"
  type        = map(any)
  default = {
    cl-shared-apps = {
      cp_range      = "172.16.0.0/28"
      pod_range     = "10.11.0.0/16"
      service_range = "10.12.0.0/16"
    }
  }
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
  type        = map(any)
  default = {
    "googleapis" = "googleapis.com."
    "gcr"        = "gcr.io."
  }
}
variable "projects_activate_apis" {
  description = "Google Cloud Project ID"
  type        = list(any)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "orgpolicy.googleapis.com",
    "cloudkms.googleapis.com",
    "anthos.googleapis.com",
    "gkehub.googleapis.com",
    "container.googleapis.com",
    "certificatemanager.googleapis.com",
  ]
}
variable "projects_activate_apis_seed" {
  description = "Google Cloud Project ID"
  type        = list(any)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "orgpolicy.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudkms.googleapis.com",
  ]
}
variable "projects_activate_apis_cx" {
  description = "Google Cloud Project ID"
  type        = list(any)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "bigquery.googleapis.com",
    "analyticshub.googleapis.com",
    "logging.googleapis.com"
  ]
}
variable "org_admins_wide_iam_roles" {
  description = "IAM roles to grant on the Cloud Organization for admins"
  type        = list(any)
  default = [
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
variable "gke_sa_roles" {
  description = "Roles to grant for the GKE node SA"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
    "roles/storage.objectViewer",
    "roles/compute.networkViewer",
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
variable "allowlisted_external_ip_ranges_v4only" {
  description = "Allowlisted external IPv4 range for GKE which acceptly only V4 addresses for control plane authorized networks"
  type        = list(string)
}
variable "gcloud_user" {
  description = "Active user in gcloud auth list - usually org admin in both orgs"
  type        = string
}
variable "billing_account_id" {
  description = "Billing Account ID"
  type        = string
}
variable "cx_billing_account_id" {
  description = "Billing Account ID used for customer projects"
  type        = string
}

# PROVIDER
variable "dns_zone_name" {
  description = "CloudDNS zone name"
  type        = string
  default     = false
}
variable "dns_domain_name" {
  description = "CloudDNS domain name used for keycloak"
  type        = string
  default     = false
}
variable "wlwfif_pool_name" {
  description = "Wload / WF Identity Federation Pool Name"
  type        = string
  default     = "test-keycloak-oidc-pool"
}
variable "wlwfif_provider_name" {
  description = "Wload / WF Identity Federation Provider Name"
  type        = string
  default     = "test-keycloak-oidc-provider"
}
variable "prov_org_id" {
  description = "Google Cloud Organization ID"
  type        = string
}
variable "prov_vpc_sc_dry_run" {
  description = "VPC SC dry-run mode"
  type        = bool
  default     = false
}
variable "prov_vpc_sc_restricted_services" {
  description = "VPC SC restricted services"
  type        = list(any)
  default     = []
}
variable "prov_project_id_prefix" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "prov_project_id_seed" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "prov_project_id_idp" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "prov_project_id_bqds" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "prov_tf_state_bucket" {
  description = "Terraform state bucket"
  type        = string
}
variable "prov_admin_user" {
  description = "Provider admin user - will get wide org-wide privileges"
  type        = string
}
variable "prov_project_owners" {
  description = "Additional IAM members to add to the provider projects"
  type        = list(any)
}
variable "prov_vpc_sc_policy_parent_org_id" {
  description = "VPC SC policy parent organization id"
  type        = string
}
variable "prov_vpc_sc_global_access_policy_name" {
  description = "VPC SC global access policy name - provider org"
  type        = string
}
variable "prov_vpc_sc_access_level_corp_ip_subnetworks" {
  description = "VPC SC access level allowed external IPs"
  type        = list(any)
  default     = []
}
variable "prov_vpc_sc_ah_customer_project_resources_with_numbers" {
  description = "VPC SC / AH allowed subscriber project numbers - format list of 'projects/project_number' items"
  type        = list(any)
  default     = []
}
variable "prov_vpc_sc_access_level_corp_allowed_identities" {
  description = "VPC SC access level allowed identities"
  type        = list(any)
  default     = []
}
variable "prov_vpc_sc_ah_customer_identities" {
  description = "VPC SC / AH allowed subscriber identities - format: list of 'user:<email>' or 'serviceAccount:<email>' items"
  type        = list(any)
  default     = []
}
variable "provider_managed_projects" {
  description = "Map of provider managed projects"
  type        = any
  default     = {}
}
variable "central_logging_project_name" {
  description = "Project name for centralized logging"
  type        = string
  default     = "central-logging"
}
variable "central_logging_project_id" {
  description = "Project ID for centralized logging"
  type        = string
  default     = "bqprovpr-bqah-central-logging"
}
variable "bq_dataset_writer_role" {
  description = "IAM role to allow log sink to write to the BigQuery dataset"
  type        = string
  default     = "roles/bigquery.dataEditor"
}
variable "bq_job_user_role" {
  description = "IAM role to allow logging service account to run BigQuery jobs"
  type        = string
  default     = "roles/bigquery.jobUser"
}
variable "logging_folder_sink" {
  description = "Name of the log sink created at the consumer projects folder level"
  type        = string
  default     = "route-to-central-logging"
}
variable "logging_bigquery_dataset" {
  description = "BigQuery dataset in central logging project"
  type        = string
  default     = "central_logs"
}