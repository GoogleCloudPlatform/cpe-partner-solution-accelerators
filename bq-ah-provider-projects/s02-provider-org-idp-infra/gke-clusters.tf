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

resource "google_container_cluster" "lab" {
  for_each = var.gke_clusters

  project  = data.google_project.project.project_id
  name     = "${each.key}-${random_string.suffix.result}"
  location = var.zone
  remove_default_node_pool = false
  initial_node_count       = 3
  networking_mode = "VPC_NATIVE"

  network                 = google_compute_network.vpc_network.id
  subnetwork              = google_compute_subnetwork.gke_subnet.id

  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = each.value.cp_range
    master_global_access_config {
        enabled = true
    }
  }

  control_plane_endpoints_config {
    dns_endpoint_config {
      allow_external_traffic = true
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name = "${each.key}-pods"
    services_secondary_range_name = "${each.key}-services"
  }

  node_config {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  timeouts {
    create = "30m"
    update = "40m"
  }

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = toset(var.allowlisted_external_ip_ranges_v4only)
      content {
        cidr_block = cidr_blocks.value
        display_name = "External Allowlisted"
      }
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
}

resource "google_gke_hub_membership" "membership" {
  for_each = var.gke_clusters

  membership_id = each.key
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.lab[each.key].id}"
    }
  }
}

resource "google_compute_global_address" "gateway" {
  name = "gateway-ip-${random_string.suffix.result}"
}
