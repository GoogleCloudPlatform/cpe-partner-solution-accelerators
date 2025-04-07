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

# Reserved internal address
resource "google_compute_address" "l7-rilb-site1" {
  name         = "l7-rilb-site1-ip"
  provider     = google-beta
  subnetwork   = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].id
  address_type = "INTERNAL"
  address      = "10.11.20.200"
  region       = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].region
  purpose      = "SHARED_LOADBALANCER_VIP"
}

# Regional forwarding rule
resource "google_compute_forwarding_rule" "l7-rilb-site1" {
  name                  = "l7-rilb-site1"
  region                = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].region
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.l7-rilb-site1.id
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = true
  port_range            = "443"
  target                = google_compute_region_target_https_proxy.l7-rilb-site1.id
  network               = data.google_compute_network.vpc_network["main"].id
  subnetwork            = data.google_compute_subnetwork.vpc_subnet["fra-webtier"].id
  network_tier          = "PREMIUM"
}

resource "google_compute_region_ssl_certificate" "site1-wildcard" {
  name_prefix = "wildcard-site1"
  private_key = file("${path.module}/../../secrets/lb_privkey.pem")
  certificate = file("${path.module}/../../secrets/lb_fullchain.pem")
  region      = var.sites["fra"].region
  lifecycle {
    create_before_destroy = true
  }
}

# Regional target HTTP proxy
resource "google_compute_region_target_https_proxy" "l7-rilb-site1" {
  name             = "l7-rilb-site1"
  region           = var.sites["fra"].region
  url_map          = google_compute_region_url_map.l7-rilb-site1.id
  ssl_certificates = [google_compute_region_ssl_certificate.site1-wildcard.self_link]
}

# Regional URL map
resource "google_compute_region_url_map" "l7-rilb-site1" {
  name            = "l7-rilb-site1"
  region          = var.sites["fra"].region
  default_service = google_compute_region_backend_service.webtier-site1.id

  host_rule {
    hosts = [ trimsuffix("site1webtier.${var.dns_custom_domain}",".") ]
    path_matcher = "webtier-site1-path-matcher-1"
  }

  path_matcher {
    default_service = google_compute_region_backend_service.webtier-site1.id
    name = "webtier-site1-path-matcher-1"

    path_rule {
      paths   = [ "/webtier/*" ]
      service = google_compute_region_backend_service.webtier-site1.id
    }
  }
}

# Regional health check
resource "google_compute_region_health_check" "hc-http-serving-port-site1" {
  name   = "l7-rilb-site1"
  region = var.sites["fra"].region
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_dns_record_set" "l7-rilb-site1" {
  name         = "site1webtier.${var.dns_custom_domain}"
  managed_zone = data.google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_address.l7-rilb-site1.address ]
}

# Regional backend service
resource "google_compute_region_backend_service" "webtier-site1" {
  name                  = "l7-rilb-webtier-site1"
  region                = var.sites["fra"].region
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "INTERNAL_MANAGED"
  timeout_sec           = 10
  health_checks         = [google_compute_region_health_check.hc-http-serving-port-site1.id]
  ip_address_selection_policy     = "IPV4_ONLY"
  locality_lb_policy              = "RING_HASH"
  backend {
    group           = google_compute_instance_group.webtier-site1.id
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

resource "google_compute_instance_group" "webtier-site1" {
  name      = "webtier-site1-grp"
  zone      = var.sites["fra"].zone
  instances = [
    google_compute_instance.vm["web1"].self_link,
    google_compute_instance.vm["web2"].self_link
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

resource "google_dns_record_set" "webtier-site1" {
  name         = "webtier-site1.${var.dns_custom_domain}"
  managed_zone = data.google_dns_managed_zone.dns.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_address.l7-rilb-site1.address ]
}
