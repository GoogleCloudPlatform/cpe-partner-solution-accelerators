resource "google_sql_database_instance" "instance" {
  name             = "db"
  region           = var.sites["fra"].region
  database_version = "SQLSERVER_2017_STANDARD"
  deletion_protection = false
  root_password    = data.google_secret_manager_secret_version.secret-database.secret_data

  settings {
    edition = "ENTERPRISE"
    tier = "db-custom-2-7680"
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.vpc_network["main"].self_link
      enable_private_path_for_google_cloud_services = false
    }
    availability_type = "ZONAL"
  }
}

resource "google_sql_user" "users" {
  name     = "dbsa"
  instance = google_sql_database_instance.instance.name
  password = data.google_secret_manager_secret_version.secret-database.secret_data
}
