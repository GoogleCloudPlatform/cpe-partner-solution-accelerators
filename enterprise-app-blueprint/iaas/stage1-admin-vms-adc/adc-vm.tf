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

#  # Admin
#  adsrv = {
#    location = "fra"
#    machine-type = "e2-standard-4"
#    gpus = []
#    network = "main"
#    subnet = "fra-main"
#    ip = "10.11.0.10"
#    comment = "Role: Active Directory + ADFS"
#    image = "windows-cloud/windows-2019"
#  }

resource "google_compute_address" "vm_ip_adsrv" {
  region       = var.sites[var.admin_vms_noauto["adsrv"].location].region
  name         = "adsrv-ip"
  address_type = "INTERNAL"
  address      = var.admin_vms_noauto["adsrv"].ip
  subnetwork   = data.google_compute_subnetwork.vpc_subnet[var.admin_vms_noauto["adsrv"].subnet].id
}

resource "google_compute_instance" "vm_adsrv" {
  name = "adsrv"
  zone = try(var.admin_vms_noauto["adsrv"].zone, "") != "" ? var.admin_vms_noauto["adsrv"].zone : var.sites[var.admin_vms_noauto["adsrv"].location].zone

  boot_disk {
    auto_delete = true
 
    initialize_params {
      image = var.admin_vms_noauto["adsrv"].image
      size  = 100
      type  = "pd-balanced"
    }
  }

  can_ip_forward = true
  machine_type   = var.admin_vms_noauto["adsrv"].machine-type

  network_interface {
    network            = data.google_compute_network.vpc_network[var.admin_vms_noauto["adsrv"].network].id
    subnetwork         = data.google_compute_subnetwork.vpc_subnet[var.admin_vms_noauto["adsrv"].subnet].id
    stack_type         = "IPV4_ONLY"
    network_ip         = google_compute_address.vm_ip_adsrv.address
  }

  service_account {
    email  = data.google_service_account.vm_sa_adsrv.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = [metadata["ssh-keys"], metadata["windows-keys"]]
  }

  scheduling {
    on_host_maintenance = "MIGRATE"
  }

  metadata = {
    ActiveDirectoryDnsDomain = var.ad_dns_domain,
    ActiveDirectoryNetbiosDomain = upper(split(".",var.ad_dns_domain)[0]),
    ActiveDirectoryFirstDc = "adsrv",
    ActiveDirectoryPwSecret = data.google_secret_manager_secret.secret-adpwd.secret_id,
    RegisterComputerPwSecret = data.google_secret_manager_secret.secret-register-computer.secret_id,
    sysprep-specialize-script-ps1 = "Install-WindowsFeature AD-Domain-Services; Install-WindowsFeature DNS",
    disable-account-manager = "true",
    windows-startup-script-ps1 = file("${path.module}/../../scripts/dc-startup.ps1")
  }
}
