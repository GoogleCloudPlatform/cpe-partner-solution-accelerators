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


# TODO: NetApp does not work with Managed AD yet out of box
#resource "google_netapp_active_directory" "mgad-policy-site1" {
#  name = "mgad-policy-site1"
#  location = var.sites["fra"].region
#  dns = "10.100.0.2,10.100.0.3"
#  organizational_unit    = "OU=Cloud,CN=Computers"
#  net_bios_prefix = "netapp"
#  username = var.managed_ad_admin_username
#  password = var.managed_ad_admin_password
#  domain = trimsuffix(var.managed_ad_dns_domain, ".")
#  administrators = [ var.managed_ad_admin_username ]
#  backup_operators = [ var.managed_ad_admin_username ]
#  security_operators = [ var.managed_ad_admin_username ]
#
#  lifecycle {
#    ignore_changes = [password]
#  }
#
#}

#resource "google_netapp_storage_pool" "spool-site1" {
#  name = "spool-site1"
#  location = var.sites["fra"].region
#  service_level = "STANDARD"
#  capacity_gib = "2048"
#  network = google_compute_network.vpc_network["main"].id
#  active_directory = google_netapp_active_directory.mgad-policy-site1.id
#}

#resource "google_netapp_volume" "mgad-vol-site1" {
#  name = "mgad-vol-site1"
#  location = var.sites["fra"].region
#  storage_pool = google_netapp_storage_pool.spool-site1.name
#  protocols = [ "SMB" ]
#  share_name = "appshare"
#  capacity_gib = 100
#}
