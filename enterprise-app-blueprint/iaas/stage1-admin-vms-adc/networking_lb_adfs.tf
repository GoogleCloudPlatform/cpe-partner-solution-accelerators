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

resource "google_compute_region_ssl_certificate" "adfs" {
  name_prefix = "adfs-wildcard-cert"
  private_key = file("${path.module}/../../secrets/privkey.pem")
  certificate = file("${path.module}/../../secrets/fullchain.pem")
  region      = var.sites["fra"].region
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group" "adfs" {
  name      = "adfs-grp"
  zone      = var.sites["fra"].zone
  instances = [
    google_compute_instance.vm_adsrv.self_link,
  ]
  named_port {
    name = "http"
    port = "80"
  }
  named_port {
    name = "https"
    port = "443"
  }
  named_port {
    name = "http-alt"
    port = "8080"
  }
  named_port {
    name = "https-alt"
    port = "8443"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_health_check" "adfs-serving-port" {
  name   = "l7-rxlb-adfs-hc"
  region = var.sites["fra"].region
  tcp_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_dns_record_set" "adfs-lb" {
  name         = "adfs.${var.dns_custom_domain}"
  managed_zone = data.google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_address.adfs-rilb.address ]
}

###################################
# Regional External Load Balancer #
###################################

# Reserved external address
resource "google_compute_address" "adfs-rxlb" {
  name         = "l7-rxlb-adfs"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  region       = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].region
}

# Regional forwarding rule
resource "google_compute_forwarding_rule" "adfs-rxlb" {
  name                  = "l7-rxlb-adfs"
  region                = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].region
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.adfs-rxlb.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.adfs-rxlb.id
  network               = data.google_compute_network.vpc_network["main"].id
#  subnetwork            = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].id
  network_tier          = "PREMIUM"
}

resource "google_dns_record_set" "adfs-rxlb" {
  name         = "adfs-rxlb.${var.dns_custom_domain}"
  managed_zone = data.google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_address.adfs-rxlb.address ]
}

# Regional backend service
resource "google_compute_region_backend_service" "adfs-rxlb" {
  name                  = "l7-rxlb-adfs"
  region                = var.sites["fra"].region
  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.adfs-serving-port.id]
  ip_address_selection_policy     = "IPV4_ONLY"
  locality_lb_policy              = "RING_HASH"
  backend {
    group           = google_compute_instance_group.adfs.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    failover        = false
    max_connections              = 0
    max_connections_per_endpoint = 0
    max_connections_per_instance = 0
    max_rate                     = 0
    max_rate_per_endpoint        = 0
    max_rate_per_instance        = 0
    max_utilization              = 0.8
  }
  consistent_hash {
    minimum_ring_size = 8
    http_cookie {
      name = "JSESSIONID"
    }
  }
}

# Regional URL map
resource "google_compute_region_url_map" "adfs-rxlb" {
  name            = "l7-rxlb-adfs"
  region          = var.sites["fra"].region
  default_service = google_compute_region_backend_service.adfs-rxlb.id

  host_rule {
    hosts = [ trimsuffix("adfs.${var.dns_custom_domain}",".") ]
    path_matcher = "adfs-path-matcher-1"
  }

  path_matcher {
    default_service = google_compute_region_backend_service.adfs-rxlb.id
    name = "adfs-path-matcher-1"

    path_rule {
      paths   = [ "/*" ]
      service = google_compute_region_backend_service.adfs-rxlb.id
    }
  }
}

# Regional target HTTP proxy
resource "google_compute_region_target_https_proxy" "adfs-rxlb" {
  name             = "l7-rxlb-adfs"
  region           = var.sites["fra"].region
  url_map          = google_compute_region_url_map.adfs-rxlb.id
  ssl_certificates = [google_compute_region_ssl_certificate.adfs.self_link]
}

###################################
# Regional Internal Load Balancer #
###################################

# Reserved internal address
resource "google_compute_address" "adfs-rilb" {
  name         = "l7-rilb-adfs"
  address_type = "INTERNAL"
  purpose      = "SHARED_LOADBALANCER_VIP"
  region       = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].region
  subnetwork   = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].id
  address      = "10.11.20.201"
}

# Regional forwarding rule
resource "google_compute_forwarding_rule" "adfs-rilb" {
  name                  = "l7-rilb-adfs"
  region                = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].region
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.adfs-rilb.id
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.adfs-rilb.id
  network               = data.google_compute_network.vpc_network["main"].id
  subnetwork            = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].id
  network_tier          = "PREMIUM"
  allow_global_access   = true
}

resource "google_dns_record_set" "adfs-rilb" {
  name         = "adfs-rilb.${var.dns_custom_domain}"
  managed_zone = data.google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_address.adfs-rilb.address ]
}

# Regional backend service
resource "google_compute_region_backend_service" "adfs-rilb" {
  name                  = "l7-rilb-adfs"
  region                = var.sites["fra"].region
  protocol              = "HTTPS"
  port_name             = "https"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.adfs-serving-port.id]  # Ensure health check exists
  ip_address_selection_policy     = "IPV4_ONLY" # Or IPV6_ONLY if needed
  locality_lb_policy              = "RING_HASH" # or other appropriate policy
  backend {
    group           = google_compute_instance_group.adfs.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    failover        = false
    max_connections              = 0
    max_connections_per_endpoint = 0
    max_connections_per_instance = 0
    max_rate                     = 0
    max_rate_per_endpoint        = 0
    max_rate_per_instance        = 0
    max_utilization              = 0.8
  }
  consistent_hash {    # Configure as needed
    minimum_ring_size = 8
    http_cookie {
      name = "JSESSIONID"
    }
  }
}


# Regional URL map
resource "google_compute_region_url_map" "adfs-rilb" {
  name            = "l7-rilb-adfs"
  region          = var.sites["fra"].region  # Replace with your region
  default_service = google_compute_region_backend_service.adfs-rilb.id # Reference the ILB backend service

  host_rule {
    hosts = [ trimsuffix("adfs.${var.dns_custom_domain}",".") ] # Adjust hostname as needed.
    path_matcher = "adfs-path-matcher-1"
  }

  path_matcher {
    default_service = google_compute_region_backend_service.adfs-rilb.id
    name = "adfs-path-matcher-1"

    path_rule {
      paths   = [ "/*" ]
      service = google_compute_region_backend_service.adfs-rilb.id
    }
  }
}

# Regional target HTTP proxy
resource "google_compute_region_target_https_proxy" "adfs-rilb" {
  name             = "l7-rilb-adfs"
  region           = var.sites["fra"].region
  url_map          = google_compute_region_url_map.adfs-rilb.id
  ssl_certificates = [google_compute_region_ssl_certificate.adfs.self_link]
}
