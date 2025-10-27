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

resource "google_compute_address" "jumphost_ip" {
  project      = data.google_project.subscr_seed_project.project_id
  name         = "jumphost-int-ip-${var.name_suffix}"
  address_type = "INTERNAL"
  address      = var.jumphost_ip
  subnetwork   = google_compute_subnetwork.vpc_subnet.id
}

resource "google_compute_instance" "jumphost_vm" {
  project      = data.google_project.subscr_seed_project.project_id
  name = "jumphost-vm-${var.name_suffix}"
  zone = var.zone

  boot_disk {
    auto_delete = true
 
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 500
      type  = "pd-ssd"
    }
  }

  can_ip_forward = false
  machine_type   = "e2-medium"

  network_interface {
    network            = google_compute_network.vpc_network.id
    subnetwork         = google_compute_subnetwork.vpc_subnet.id
    stack_type         = "IPV4_ONLY"
    network_ip         = google_compute_address.jumphost_ip.address
  }

  service_account {
    email  = google_service_account.jumphost_sa.email
    scopes = ["cloud-platform"]
  }

  allow_stopping_for_update = true

  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}
