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

resource "google_compute_address" "vm_ip" {
  for_each                           = var.app_vms

  region       = var.sites[each.value.location].region
  name         = "${each.key}-ip"
  address_type = "INTERNAL"
  address      = each.value.ip
  subnetwork   = data.google_compute_subnetwork.vpc_subnet[each.value.subnet].id
}

resource "google_compute_instance" "vm" {
  for_each                           = var.app_vms

  name = each.key
  zone = try(each.value.zone, "") != "" ? each.value.zone : var.sites[each.value.location].zone

  boot_disk {
    auto_delete = true
 
    initialize_params {
      image = each.value.image
      size  = 100
      type  = "pd-balanced"
    }
  }

  can_ip_forward = true
  machine_type   = each.value.machine-type

  network_interface {
    network            = data.google_compute_network.vpc_network[each.value.network].id
    subnetwork         = data.google_compute_subnetwork.vpc_subnet[each.value.subnet].id
    stack_type         = "IPV4_ONLY"
    network_ip         = google_compute_address.vm_ip[each.key].address
  }

  service_account {
    email  = data.google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = [metadata["ssh-keys"], metadata["windows-keys"]]
  }

  scheduling {
    on_host_maintenance = try(each.value.on_host_maintenance, "MIGRATE")
  }

  dynamic "guest_accelerator" {
    for_each = toset(each.value.gpus)
    content {
      type = guest_accelerator.value.type
      count = guest_accelerator.value.count
    }
  }

  metadata = {
    sysprep-specialize-script-ps1 = "iex((New-Object System.Net.WebClient).DownloadString('${data.terraform_remote_state.stage1-admin-vms-adc.outputs.regfunc_url}'))"
  }
}

resource "google_dns_record_set" "vm-a" {
  for_each                           = var.app_vms

  name         = "${each.key}.${var.dns_custom_domain}"
  managed_zone = data.google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_address.vm_ip[each.key].address ]
}
