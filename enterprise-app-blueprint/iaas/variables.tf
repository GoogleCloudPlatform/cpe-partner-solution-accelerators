variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}
variable "networks" {
  description = "Networks to create networks in"
  type        = map(any)
}
variable "sites" {
  description = "Deployment sites (logica sites map to Google Cloud regions)"
  type        = map(any)
}
variable "admin_vms_noauto" {
  description = "Admin VMs: Active Directory Controller"
  type        = any
}
variable "admin_vms" {
  description = "Admin VMs: Jumphost, etc"
  type        = any
}
variable "app_vms" {
  description = "Application VMs (Web, Application, etc tiers)"
  type        = any
}
variable "dns_custom_domain" {
  description = "Custom DNS domain name"
  type        = string
}
variable "dns_zone_name" {
  description = "Custom DNS zone resource name"
  type        = string
}
variable "ad_secret_expires" {
  description = "Time when the AD secret read IAM permission granted to the adsrv service account expires"
  type        = string
}
variable "ad_dns_domain" {
  description = "Active Directory DNS domain name"
  type        = string
}
variable "ad_admin_username" {
  description = "Active Directory Administrator who can add machines to the domain"
  type        = string
}
variable "ad_register_image" {
  description = "Active Directory Register Cloud Run App Image"
  type        = string
}
variable "ad_register_projects_dn" {
  description = "Active Directory DN for the Projects OU"
  type        = string
}
variable "ad_register_username" {
  description = "Active Directory registration user who can add machines to the domain"
  type        = string
}
variable "allowlisted_external_ip_ranges" {
  description = "Allowlisted external range for GKE, SSH, etc"
  type        = list(string)
}
variable "allowlisted_external_ip_ranges_v6only" {
  description = "Allowlisted external IPv6 range for GKE, SSH, etc"
  type        = list(string)
}
variable "allowlisted_external_ip_ranges_v4only" {
  description = "Allowlisted external IPv4 range for GKE, SSH, etc"
  type        = list(string)
}
variable "tf_state_bucket" {
  description = "Terraform state bucket"
  type        = string
}

variable "psa_ip" {
  description = "Private service access (PSA) CIDR range"
  type        = string
  default     = "10.250.0.0"
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
variable "vm_sa_roles" {
  description = "Roles to grant for the VM SA"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
    "roles/storage.objectViewer",
    "roles/compute.networkViewer",
  ]
}
variable "regfunc_sa_roles" {
  description = "Roles to grant for the regfunc SA"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/artifactregistry.reader",
    "roles/storage.objectViewer",
    "roles/compute.networkViewer",
    "roles/viewer",
  ]
}

