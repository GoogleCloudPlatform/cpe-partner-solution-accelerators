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

resource "google_netapp_active_directory" "ad-policy-site1" {
  name = "ad-policy-site1"
  location = var.sites["fra"].region
  dns = data.google_compute_address.vm_ip_adsrv.address
  net_bios_prefix = "netapp"
  username = var.ad_admin_username
  password = data.google_secret_manager_secret_version.secret-adpwd.secret_data
#  username = split("\\", var.ad_register_username)[1]
#  password = data.google_secret_manager_secret_version.secret-register-computer.secret_data
  domain = trimsuffix(var.ad_dns_domain, ".")
  administrators = [ var.ad_admin_username ]
  backup_operators = [ var.ad_admin_username ]
  security_operators = [ var.ad_admin_username ]
  organizational_unit = "OU=${data.google_project.project.project_id},OU=Projects"
}

resource "google_netapp_storage_pool" "spool-site1" {
  name = "spool-site1"
  location = var.sites["fra"].region
  service_level = "STANDARD"
  capacity_gib = "2048"
  network = data.google_compute_network.vpc_network["main"].id
  active_directory = google_netapp_active_directory.ad-policy-site1.id
}

resource "google_netapp_volume" "vol-site1" {
  name = "vol-site1"
  location = var.sites["fra"].region
  storage_pool = google_netapp_storage_pool.spool-site1.name
  protocols = [ "SMB" ]
  share_name = "appdata"
  capacity_gib = 100
}
