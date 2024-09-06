resource "google_dns_managed_zone" "pga" {
  for_each      = var.pga_domains

  project       = data.google_project.prov_seed_project.project_id
  name          = "${each.key}-pga-${var.name_suffix}"
  dns_name      = each.value
  force_destroy = false
  visibility    = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc_network.id
    }
  }
}

resource "google_dns_record_set" "pga_cname" {
  for_each = var.pga_domains
  
  name         = "*.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["private.${each.value}"]
}

resource "google_dns_record_set" "pga_a" {
  for_each = var.pga_domains
  
  name         = "private.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

resource "google_dns_record_set" "pga_dom_a" {
  for_each = var.pga_domains
  
  name         = "${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}
