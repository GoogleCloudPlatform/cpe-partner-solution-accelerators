resource "google_dns_managed_zone" "pga" {
  for_each      = var.pga_domains

  project       = google_project.publ_cs_cx_foo_project.name
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
  
  project       = google_project.publ_cs_cx_foo_project.name
  name         = "*.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["restricted.${each.value}"]
}

resource "google_dns_record_set" "pga_a" {
  for_each = var.pga_domains
  
  project       = google_project.publ_cs_cx_foo_project.name
  name         = "restricted.${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}

resource "google_dns_record_set" "pga_dom_a" {
  for_each = var.pga_domains
  
  project       = google_project.publ_cs_cx_foo_project.name
  name         = "${each.value}"
  managed_zone = google_dns_managed_zone.pga["${each.key}"].name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}
